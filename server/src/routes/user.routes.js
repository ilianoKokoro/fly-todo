import express from "express";
import HttpErrors from "http-errors";

import explorerRepository from "../repositories/explorer.repository.js";

import {
    guardAuthorizationJWT,
    guardRefreshJWT,
    guardAccess,
} from "../middlewares/authorization.jwt.js";
import blacklistExpiredRefreshToken from "../middlewares/blacklist.refreshToken.js";
import explorerValidator from "../validators/explorer.validator.js";
import validator from "../middlewares/validator.js";

const router = express.Router();

class ExplorerRouter {
    constructor() {
        router.post("/", explorerValidator.complete(), validator, this.signup);
        router.post("/actions/login", explorerValidator.partial(), this.login);
        router.post(
            "/actions/refresh",
            blacklistExpiredRefreshToken,
            guardRefreshJWT,
            this.refreshTokens
        );
        router.get(
            "/:explorer_uuid",
            guardAuthorizationJWT,
            guardAccess,
            this.getOne
        );
        router.get(
            "/:explorer_uuid/inventory",
            guardAuthorizationJWT,
            guardAccess,
            this.getInventory
        );
        router.delete("/actions/logout", guardAuthorizationJWT, this.logout);
    }

    async signup(req, res, next) {
        try {
            let explorer = await explorerRepository.create(req.body);

            explorer = explorer.toObject({ getters: false, virtuals: false });
            const tokens = explorerRepository.generateJWT(explorer, true);
            explorer = explorerRepository.transform(explorer);

            res.status(201).json({ explorer, tokens });
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

            const loginResult = await explorerRepository.login(name, password);

            if (loginResult.explorer) {
                let explorer = loginResult.explorer.toObject({
                    getters: false,
                    virtuals: false,
                });
                const tokens = explorerRepository.generateJWT(explorer, true);
                explorer = explorerRepository.transform(explorer);

                res.status(201).json({ explorer, tokens });
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

            const validateResult =
                await explorerRepository.validateRefreshToken(uuid, headerName);

            if (!validateResult.validate) {
                throw HttpErrors.Forbidden("Invalid refresh token.");
            }

            await explorerRepository.blacklistAccessToken(oldAccessToken);

            const tokens = explorerRepository.generateJWT(
                validateResult.explorer
            );

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

            await explorerRepository.logout(accessToken, refreshToken);
            res.status(204).end();
        } catch (err) {
            return next(err);
        }
    }

    async getInventory(req, res, next) {
        try {
            let explorer = await explorerRepository.retrieveOneWithFields(
                req.params.explorer_uuid,
                "inox essence elements uuid"
            );

            explorer = explorer.toObject({ getters: false, virtuals: false });
            explorer = explorerRepository.transform(explorer);
            res.status(200).json(explorer);
        } catch (err) {
            return next(err);
        }
    }

    async getOne(req, res, next) {
        try {
            let explorer = await explorerRepository.retrieveOne(
                req.params.explorer_uuid
            );
            explorer = explorer.toObject({ getters: false, virtuals: false });
            explorer = explorerRepository.transform(explorer);

            res.status(200).json(explorer);
        } catch (err) {
            return next(err);
        }
    }
}

new ExplorerRouter();

export default router;
