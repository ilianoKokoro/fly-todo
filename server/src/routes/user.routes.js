import express from "express";
import HttpErrors from "http-errors";

import userRepository from "../repositories/user.repository.js";

import {
    guardAuthorizationJWT,
    guardRefreshJWT,
    guardAccess,
} from "../middlewares/authorization.jwt.js";
import blacklistExpiredRefreshToken from "../middlewares/blacklist.refreshToken.js";
import userValidator from "../validators/user.validator.js";
import validator from "../middlewares/validator.js";

const router = express.Router();

class UserRouter {
    constructor() {
        router.post("/", userValidator.complete(), validator, this.signup);
        router.post("/actions/login", userValidator.partial(), this.login);
        router.post(
            "/actions/refresh",
            blacklistExpiredRefreshToken,
            guardRefreshJWT,
            this.refreshTokens
        );
        router.get(
            "/:user_uuid",
            guardAuthorizationJWT,
            guardAccess,
            this.getOne
        );
        router.delete("/actions/logout", guardAuthorizationJWT, this.logout);
    }

    async signup(req, res, next) {
        try {
            let user = await userRepository.create(req.body);

            user = user.toObject({ getters: false, virtuals: false });
            const tokens = userRepository.generateJWT(user, true);
            user = userRepository.transform(user);

            res.status(201).json({ user, tokens });
        } catch (err) {
            return next(err);
        }
    }

    async login(req, res, next) {
        try {
            const { name, password } = req.body;

            if (!name || !password) {
                throw HttpErrors.BadRequest(
                    "Both 'name' and 'password' fields are required."
                );
            }

            const loginResult = await userRepository.login(name, password);

            if (loginResult.user) {
                let user = loginResult.user.toObject({
                    getters: false,
                    virtuals: false,
                });
                const tokens = userRepository.generateJWT(user, true);
                user = userRepository.transform(user);

                res.status(200).json({ user, tokens });
            }
        } catch (err) {
            return next(err);
        }
    }

    async refreshTokens(req, res, next) {
        try {
            const uuid = req.refresh?.uuid;
            const headerName = req.headers.name;
            const oldAccessToken = req.headers.authorization?.split(" ")[1];
            const refreshToken = req.body.refreshToken;

            if (!uuid || !oldAccessToken || !refreshToken) {
                throw HttpErrors.BadRequest(
                    "Missing 'uuid', 'accessToken', or 'refreshToken'."
                );
            }

            const validateResult = await userRepository.validateRefreshToken(
                uuid,
                headerName
            );

            if (!validateResult.validate) {
                throw HttpErrors.Forbidden("Invalid refresh token.");
            }

            await userRepository.blacklistAccessToken(oldAccessToken);

            const tokens = userRepository.generateJWT(validateResult.user);

            res.status(201).json({ tokens });
        } catch (err) {
            return next(err);
        }
    }

    async logout(req, res, next) {
        try {
            const accessToken = req.headers.authorization?.split(" ")[1]; // Assuming Bearer token
            const refreshToken = req.body.refreshToken;

            if (!accessToken || !refreshToken) {
                throw new HttpErrors.BadRequest(
                    "Access or refresh token missing."
                );
            }

            await userRepository.logout(accessToken, refreshToken);
            res.status(204).end();
        } catch (err) {
            return next(err);
        }
    }

    async getOne(req, res, next) {
        try {
            let user = await userRepository
                .retrieveOne(req.params.user_uuid)
                .populate("tasks");
            user = user.toObject({ getters: false, virtuals: true });
            user = userRepository.transform(user);

            res.status(200).json(user);
        } catch (err) {
            return next(err);
        }
    }
}

new UserRouter();

export default router;
