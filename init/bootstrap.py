from rucio.db.sqla.util import (build_database, create_base_vo,
                                create_root_account)

if __name__ == '__main__':
    build_database()
    create_base_vo()
    create_root_account()
