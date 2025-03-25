import Tasks from "../models/task.model.js";
class TasksRepository {
    retrieveOne(uuid) {
        const task = Tasks.findOne({ uuid: uuid });
        return task;
    }

    async create(task) {
        try {
            return await Tasks.create(task);
        } catch (err) {
            throw err;
        }
    }

    async delete(uuid) {
        try {
            await Tasks.deleteOne({ uuid: uuid });
        } catch (err) {
            throw err;
        }
    }

    async edit(body, task_uuid) {
        const update = { name: body.name, isCompleted: body.isCompleted };

        return await Tasks.findOneAndUpdate(
            {
                uuid: task_uuid,
            },
            { $set: update },
            { new: true }
        );
    }

    transform(task, user_uuid) {
        task.href = `${process.env.BASE_URL}/users/${user_uuid}/tasks/${task.uuid}`;

        delete task.user;
        delete task._id;
        delete task.uuid;
        delete task.__v;

        return task;
    }
}

export default new TasksRepository();
