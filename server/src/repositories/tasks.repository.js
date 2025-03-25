import Tasks from "../models/task.model.js";
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
        task.href = `${process.env.BASE_URL}/tasks/${planet._id}`;

        delete user._id;
        delete user.uuid;
        delete user.__v;

        return task;
    }
}

export default new TasksRepository();
