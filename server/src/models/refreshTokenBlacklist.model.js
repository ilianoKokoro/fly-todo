import mongoose from "mongoose";

const RefreshTokenBlacklistSchema = new mongoose.Schema(
    {
        token: { type: String, required: true },
        createdAt: { type: Date, expires: "7d", default: Date.now }, // Auto-remove after 7 days
    },
    {
        collection: "refreshtokenblacklist",
        strict: "throw",
        id: false,
    }
);

const RefreshTokenBlacklist = mongoose.model(
    "RefreshTokenBlacklist",
    RefreshTokenBlacklistSchema
);

export default RefreshTokenBlacklist;
