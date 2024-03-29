# LobeChat Assistant Library

This project is a library for Hanako's private LobeChat assistant, which is hosted on CloudFlare Workers. The main service file is `worker.js`, which retrieves data first from this repository and then from the official LobeChat server if data is not found in this repository.

To use this library, simply add the following environment variable to your LobeChat environment settings:

`AGENTS_INDEX_URL=https://chat-agents.hanako.me`
