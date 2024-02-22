module.exports = {
  apps: [
    {
      name: "rucio-webui",
      script: "npm start",
      env: {
        NODE_ENV: "production",
      },
    },
  ],
};
