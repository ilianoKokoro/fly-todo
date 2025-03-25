import express from "express";
import HttpErrors from "http-errors";

import {
    guardAuthorizationJWT,
    guardAccess,
} from "../middlewares/authorization.jwt.js";
import tasksRepository from "../repositories/tasks.repository.js";
import userRepository from "../repositories/user.repository.js";

const router = express.Router();

class TaskRouter {
    constructor() {
        router.post(
            "/:user_uuid/tasks",
            guardAuthorizationJWT,
            guardAccess,
            this.create
        );
        router.delete(
            "/:user_uuid/tasks/:task_uuid",
            guardAuthorizationJWT,
            guardAccess,
            this.delete
        );
        router.patch(
            "/:user_uuid/tasks/:task_uuid",
            guardAuthorizationJWT,
            guardAccess,
            this.edit
        );
    }

    async create(req, res, next) {
        try {
            const userUuid = req.params.user_uuid;
            req.body.user = await userRepository.retrieveOne(userUuid);
            let task = await tasksRepository.create(req.body);

            task = task.toObject({ getters: false, virtuals: true });
            task = tasksRepository.transform(task, userUuid);

            res.status(201).json(task);
        } catch (err) {
            return next(err);
        }
    }

    async delete(req, res, next) {
        try {
            const taskId = req.params.task_uuid;
            const task = await tasksRepository.retrieveOne(taskId);

            if (!task) {
                throw HttpErrors.NotFound("Task not found.");
            }

            await tasksRepository.delete(taskId);
            res.status(200).json();
        } catch (err) {
            return next(err);
        }
    }

    async edit(req, res, next) {
        try {
            let task = await tasksRepository.edit(
                req.body,
                req.params.task_uuid
            );
            task = task.toObject({ getters: false, virtuals: true });
            task = tasksRepository.transform(task, req.params.user_uuid);

            res.status(201).json(task);
        } catch (err) {
            return next(err);
        }
    }
}

new TaskRouter();

export default router;
