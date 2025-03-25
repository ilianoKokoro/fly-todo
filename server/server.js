import { env } from "node:process";
import chalk from "chalk";

import app from "./src/app.js";

app.listen(env.PORT, (err) => {
    if (err) {
        process.exit(1);
    }

    console.log(`Loading environment for ${env.ENV}`);
    console.log(chalk.blue(`Server listening on port: ${env.PORT}`));
});
