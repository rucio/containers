#!/usr/bin/env python3
import argparse
import configparser
import logging
import json
import os
import sys
from collections import defaultdict


# Multi-word sections used in kubernetes are slightly different from what rucio expects.
# Usually, it's just a .replace('-', '_'), but not for hermes2, which doesn't follow any convention.
multi_word_sections = {
    'messaging_fts3': 'messaging-fts3',
    'messaging_cache': 'messaging-cache',
    'messaging_hermes': 'messaging-hermes',
    'messaging_hermes2': 'hermes',
    'nongrid_trace': 'nogrid-trace',
    'tracer_kronos': 'tracer-kronos',
}


def load_flat_config(flat_config):
    """
    takes a dict of the form: {"section_option": "value"}
    and converts to {"section": {"option": "value"}
    """
    config_dict = defaultdict(dict)
    for flat_key, config_value in flat_config.items():
        section = option = None
        # Try parsing a multi-word section
        for mw_key in multi_word_sections:
            if flat_key.startswith(mw_key + '_'):
                section = mw_key
                option = flat_key[len(mw_key) + 1:]

        # It didn't match any known multi-word section, assume it's a single word
        if not section:
            section, option = flat_key.split('_', maxsplit=1)

        config_dict[section][option] = config_value
    return config_dict


def fix_multi_word_sections(config_dict):
    return {multi_word_sections.get(section, section): config_for_section for section, config_for_section in config_dict.items()}


def config_len(config_dict):
    return sum(len(option) for _, option in config_dict.items())


def merge_configs(source_file_paths, dest_file_path, use_env=True):
    """
    Merge multiple configuration sources into one rucio.cfg.
    On conflicting values, relies on the default python's ConfigParser behavior: the value from last source wins.

    Sources can be either .ini or .json files. Json is supported as a compromise solution for easier integration
    with kubernetes (because both python and helm natively support it).

    If use_env=True, env variables starting with RUCIO_CFG_ are also merged as the last (highest priority) source.
    """

    parser = configparser.ConfigParser()
    for file_path in source_file_paths:
        if not os.path.exists(file_path):
            logging.warning(f"Skipping config file {file_path}: file doesn't exist")
            continue

        try:
            if file_path.endswith('.json'):
                with open(file_path,'r') as f:
                    file_config = fix_multi_word_sections(json.load(f))
                    parser.read_dict(file_config)
            else:
                local_parser = configparser.ConfigParser()
                local_parser.read(file_path)
                file_config = {section: {option: value for option, value in section_proxy.items()} for section, section_proxy in local_parser.items()}

            parser.read_dict(file_config)
            logging.info(f"Merged {config_len(file_config)} configuration values from {file_path}")
        except Exception as error:
            logging.warning(f"Skipping config file {file_path} due to error: {error}")

    if use_env:
        # env variables use the following format: "RUCIO_CFG_{section.substitute('-','_').upper}_{option.substitute('-', '_').upper}"
        env_config = {}
        for env_key, env_value in os.environ.items():
            rucio_cfg_prefix = 'RUCIO_CFG_'
            if not env_key.startswith(rucio_cfg_prefix):
                continue
            env_key = env_key[len(rucio_cfg_prefix):].lower()  # convert "RUCIO_CFG_WHATEVER" to "whatever"
            env_config[env_key] = env_value

        env_config = fix_multi_word_sections(load_flat_config(env_config))
        parser.read_dict(env_config)
        logging.info(f"Merged {config_len(env_config)} configuration values from ENV")

    if dest_file_path:
        with open(dest_file_path, 'w') as dest_file:
            parser.write(dest_file)
    else:
        parser.write(sys.stdout)

if __name__ == "__main__":
    logging.getLogger().setLevel(logging.INFO)
    parser = argparse.ArgumentParser(description="Merge multiple rucio configuration sources into one rucio.cfg")
    parser.add_argument("--use-env", action="store_true", default=False, help='Also source config from RUCIO_CFG_* env variables')
    parser.add_argument('-s', '--source', type=str, nargs='*', help='Source config file paths (in .json or .ini format)')
    parser.add_argument('-d', '--destination', default=None, help='Destination file path')
    args = parser.parse_args()

    merge_configs(args.source, args.destination, use_env=args.use_env)
