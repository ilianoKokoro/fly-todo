import cors from "cors";
import express from "express";

import errors from "./middlewares/errors.js";
import database from "./core/database.js";

const app = express();

database();

app.use(cors());
app.use(express.json());

app.use(errors);

export default app;
