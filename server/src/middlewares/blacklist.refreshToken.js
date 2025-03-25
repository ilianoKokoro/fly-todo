import jwt from "jsonwebtoken";
import ExplorerRepository from "../repositories/explorer.repository.js";

const blacklistExpiredRefreshToken = async (req, res, next) => {
    const refreshToken = req.body.refreshToken;

    if (!refreshToken) {
        return res.status(400).json({ error: "Refresh token is required" });
    }

    try {
        // Verify the refresh token
        jwt.verify(
            refreshToken,
            process.env.JWT_REFRESH_SECRET,
            async (err, decoded) => {
                if (err && err.name === "TokenExpiredError") {
                    // Token is expired, blacklist it
                    await ExplorerRepository.blacklistRefreshToken(
                        refreshToken
                    );

                    console.log(
                        "Refresh token expired and blacklisted:",
                        refreshToken
                    );

                    return res.status(401).json({
                        error: "Refresh token expired. Please log in again.",
                    });
                }

                next(); // Continue to the next middleware if token is valid
            }
        );
    } catch (err) {
        console.error("Error verifying refresh token:", err);
        return res.status(500).json({ error: "Internal server error" });
    }
};

export default blacklistExpiredRefreshToken;
