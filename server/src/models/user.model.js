import mongoose from "mongoose";
import { v4 as uuidv4 } from "uuid";

const userSchema = mongoose.Schema(
    {
        name: { type: String, required: true, unique: true },
        email: { type: String, required: true, unique: true },
        passwordHash: { type: String, required: true },
        uuid: { type: String, required: true, unique: true, default: uuidv4 },
    },
    {
        collection: "users",
        strict: "throw",
        id: false,
    }
);

userSchema.virtual("tasks", {
    ref: "Task",
    localField: "uuid",
    foreignField: "user",
    justOne: false,
});

export default mongoose.model("User", userSchema);
