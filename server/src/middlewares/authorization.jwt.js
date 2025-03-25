import HttpErrors from "http-errors";
import { expressjwt as expressJWT } from "express-jwt";
import AccessTokenBlacklist from "../models/accessTokenBlacklist.model.js";
import RefreshTokenBlacklist from "../models/refreshTokenBlacklist.model.js";
import explorerRepository from "../repositories/explorer.repository.js";

const guardAuthorizationJWT = expressJWT({
    secret: process.env.JWT_TOKEN_SECRET,
    issuer: process.env.BASE_URL,
    algorithms: ["HS256"],
    isRevoked: async (req, token) => {
        token = req.headers.authorization.split(" ")[1];
        const blacklistedToken = await AccessTokenBlacklist.findOne({ token });
        return blacklistedToken ? true : false;
    },
});

const guardRefreshJWT = expressJWT({
    secret: process.env.JWT_REFRESH_SECRET,
    issuer: process.env.BASE_URL,
    algorithms: ["HS256"],
    requestProperty: "refresh",
    getToken: (req) => {
        return req.body.refreshToken;
    },
    isRevoked: async (req, token) => {
        token = req.body.refreshToken;
        const blacklistedToken = await RefreshTokenBlacklist.findOne({ token });
        return blacklistedToken ? true : false;
    },
});

const guardAccess = async (req, res, next) => {
    try {
        if (!req.params.explorer_uuid) {
            throw HttpErrors.BadRequest("Explorer UUID is required.");
        }

        const explorer = await explorerRepository.retrieveOne(
            req.params.explorer_uuid
        );

        if (!explorer) {
            throw HttpErrors.NotFound("Explorer not found.");
        }

        if (req.auth.name !== explorer.name) {
            throw HttpErrors.Forbidden(
                "You are not authorized to access this resource."
            );
        }

        next();
    } catch (err) {
        next(err);
    }
};

export { guardAuthorizationJWT, guardRefreshJWT, guardAccess };
