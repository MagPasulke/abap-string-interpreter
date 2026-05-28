import {startServer} from './helpers/icf-server.mjs';

const server = await startServer();

// Keep process alive; graceful shutdown on SIGINT/SIGTERM
process.on('SIGINT', () => { server.close(); process.exit(0); });
process.on('SIGTERM', () => { server.close(); process.exit(0); });
