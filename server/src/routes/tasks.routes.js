import express from "express";

import userRepository from "../repositories/user.repository.js";
import { guardAuthorizationJWT } from "../middlewares/authorization.jwt.js";
import tasksRepository from "../repositories/tasks.repository.js";

const router = express.Router();

class TaskRouter {
    constructor() {
        router.post("/", guardAuthorizationJWT, this.create);
    }

    async create(req, res, next) {
        try {
            const userName = req.auth.name;
            const user = await userRepository.retrieveOneByName(userName);
            req.body.user = user;

            let task = await tasksRepository.create(req.body, userName);

            task = task.toObject({ getters: false, virtuals: false });

            res.status(201).json(task);
        } catch (err) {
            return next(err);
        }
    }
}

new TaskRouter();

export default router;
