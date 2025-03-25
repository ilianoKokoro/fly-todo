import mongoose from "mongoose";
import { v4 as uuidv4 } from "uuid";

const taskSchema = mongoose.Schema(
    {
        name: { type: String, required: true, default: "" },
        isCompleted: { type: Boolean, required: true, default: false },
        uuid: { type: String, required: true, unique: true, default: uuidv4 },
        user: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
    },
    {
        collection: "tasks",
        strict: "throw",
        id: false,
    }
);

export default mongoose.model("Task", taskSchema);
