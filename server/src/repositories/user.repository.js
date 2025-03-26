import HttpErrors from "http-errors";
import argon from "argon2";
import jwt from "jsonwebtoken";

import User from "../models/user.model.js";
import AccessTokenBlacklist from "../models/accessTokenBlacklist.model.js";
import RefreshTokenBlacklist from "../models/refreshTokenBlacklist.model.js";
import tasksRepository from "./tasks.repository.js";

class UserRepository {
    retrieveOne(uuid) {
        const user = User.findOne({ uuid: uuid });
        return user;
    }

    retrieveOneWithFields(uuid, fields) {
        const user = User.findOne({ uuid: uuid }, fields);
        return user;
    }

    retrieveOneByName(name) {
        const user = User.findOne({ name: name });
        return user;
    }

    retrieveAll() {
        const user = User.find({});
        return user;
    }

    async login(name, password) {
        try {
            const user = await User.findOne({ name: name });

            if (!user || !(await this.validatePassword(password, user))) {
                throw HttpErrors.Unauthorized("Invalid username or password.");
            }

            return { user: user };
        } catch (err) {
            throw err;
        }
    }

    async validatePassword(password, user) {
        return await argon.verify(user.passwordHash, password);
    }

    async create(user) {
        try {
            user.passwordHash = await argon.hash(user.password);
            delete user.password;
            const newUser = await User.create(user);

            return newUser;
        } catch (err) {
            throw err;
        }
    }

    generateJWT(user) {
        try {
            const accessToken = jwt.sign(
                { name: user.name },
                process.env.JWT_TOKEN_SECRET,
                {
                    expiresIn: process.env.JWT_TOKEN_LIFE,
                    issuer: process.env.BASE_URL,
                }
            );

            const refreshToken = jwt.sign(
                { uuid: user.uuid },
                process.env.JWT_REFRESH_SECRET,
                {
                    expiresIn: process.env.JWT_REFRESH_LIFE,
                    issuer: process.env.BASE_URL,
                }
            );

            return { accessToken, refreshToken };
        } catch (err) {
            throw err;
        }
    }

    async validateRefreshToken(uuid, headerName) {
        try {
            const user = await User.findOne({ name: uuid });

            if (!user) {
                throw HttpErrors.NotFound("User not found.");
            }

            return {
                validate: user.name === headerName,
                user: user,
            };
        } catch (err) {
            throw err;
        }
    }

    async logout(accessToken, refreshToken) {
        try {
            await AccessTokenBlacklist.create({ token: accessToken });
            await RefreshTokenBlacklist.create({ token: refreshToken });
        } catch (err) {
            throw err;
        }
    }

    async blacklistAccessToken(accessToken) {
        try {
            await AccessTokenBlacklist.create({ token: accessToken });
        } catch (err) {
            throw err;
        }
    }

    async blacklistRefreshToken(refreshToken) {
        try {
            await RefreshTokenBlacklist.create({ token: refreshToken });
        } catch (err) {
            throw err;
        }
    }

    transform(user) {
        user.href = `${process.env.BASE_URL}/users/${user.uuid}`;

        if (user.tasks) {
            user.tasks.map((t) => {
                t = tasksRepository.transform(t, user.uuid);
                return t;
            });
        }

        delete user._id;
        delete user.uuid;
        delete user.passwordHash;
        delete user.__v;

        return user;
    }
}

export default new UserRepository();
