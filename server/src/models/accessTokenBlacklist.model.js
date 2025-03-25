import mongoose from "mongoose";

const AccessTokenBlacklistSchema = new mongoose.Schema(
    {
        token: { type: String, required: true },
        createdAt: { type: Date, expires: "30m", default: Date.now }, // Auto-remove after 30 minutes
    },
    {
        collection: "accesstokenblacklist",
        strict: "throw",
        id: false,
    }
);

const AccessTokenBlacklist = mongoose.model(
    "AccessTokenBlacklist",
    AccessTokenBlacklistSchema
);

export default AccessTokenBlacklist;
