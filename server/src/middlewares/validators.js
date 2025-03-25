import expressValidator from "express-validator";
const { validationResult } = expressValidator;

export default (req, res, next) => {
    const errors = validationResult(req);
    if (errors.isEmpty()) {
        return next();
    }

    const extractedErrors = [];
    errors.array().map((err) => extractedErrors.push({ [err.path]: err.msg }));

    return res.status(422).json({ errors: extractedErrors });
};
