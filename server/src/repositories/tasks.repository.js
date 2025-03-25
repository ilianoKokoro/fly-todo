import { isObjectIdOrHexString } from "mongoose";
import Tasks from "../models/task.model.js";
import userRepository from "./user.repository.js";
class TasksRepository {
    retrieveOne(uuid) {
        const user = Tasks.findOne({ uuid: uuid });
        return user;
    }

    retrieveOneByUser(uuid) {
        const user = Tasks.findOne({ user: uuid });
        return user;
    }

    async create(task) {
        try {
            return await Tasks.create(task);
        } catch (err) {
            throw err;
        }
    }

    transform(task) {
        task.href = `${process.env.BASE_URL}/tasks/${task.uuid}`;

        //task.user = userRepository.transform(task.user);
        delete task.user;

        delete task._id;
        delete task.uuid;
        delete task.__v;

        return task;
    }
}

export default new TasksRepository();
