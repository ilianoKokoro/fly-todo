import mongoose from "mongoose";
import httpErrors from "http-errors";

export default (err, req, res, next) => {
    const error = {
        developerMessage: err.stack,
        userMessage: err.message,
    };

    if (httpErrors.isHttpError(err)) {
        error.status = err.status;
    } else {
        if (err.name === "MongoServerError") {
            switch (err.code) {
                case 11000:
                    error.status = 409;
                    if (err.keyValue) {
                        const property = Object.keys(err.keyValue)[0];
                        const value = err.keyValue[property];
                        error.userMessage = `The property ${property} with the value ${value} is not unique.`;
                    } else {
                        error.userMessage = `One of the information entered is not unique.`;
                    }
            }
        }

        if (err instanceof mongoose.Error.ValidationError) {
            error.status = 422;
            error.userMessage = err.message;
        } else if (err instanceof mongoose.Error.CastError) {
            if (err.kind === "ObjectId") {
                error.status = 404;
                error.developerMessage = err.stack;
            }
        }

        //JWT Error
        if (err.status) {
            error.status = err.status;
        }

        //Catch all -> 500
        if (!error.status) {
            error.status = 500;
        }
    }

    error.moreInfo = `http://documentation/errors/${error.status}`;

    if (process.env.NODE_ENV === "development") {
        console.log(error.developerMessage);
    } else if (process.env.NODE_ENV === "production") {
        delete error.developerMessage;
        //TODO: Log error.developerMessage
    }

    res.status(error.status).json(error);
};
