import expressValidator from "express-validator";

const { body } = expressValidator;

class UserValidators {
    complete() {
        return [
            body("name").exists().withMessage("Required").bail(),
            body("password").exists().withMessage("Required").bail(),
            ...this.partial(),
        ];
    }

    partial() {
        return [
            body("name")
                .optional()
                .isLength({ min: 2, max: 16 })
                .withMessage(
                    "The username must have between 2 and 16 characters"
                )
                .bail(),

            body("email")
                .optional()
                .trim()
                .isEmail()
                .withMessage("The email entered is invalid")
                .bail(),

            body("password")
                .optional()
                .isStrongPassword({
                    minLength: 8,
                    minLowercase: 1,
                    minUppercase: 1,
                    minNumbers: 1,
                    minSymbols: 1,
                })
                .withMessage(
                    "The password must be at least 8 characters, with at least a lowercase letter, an uppercase letter, a number and a symbol"
                )
                .bail(),
        ];
    }
}

export default new UserValidators();
