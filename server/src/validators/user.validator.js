import expressValidator from "express-validator";

const { body } = expressValidator;

class UserValidators {
    complete() {
        return [
            body("name").exists().withMessage("Requis").bail(),
            body("password").exists().withMessage("Requis").bail(),
            ...this.partial(),
        ];
    }

    partial() {
        return [
            body("name")
                .optional()
                .isLength({ min: 2, max: 16 })
                .withMessage("Le nom doit comporter entre 2 et 16 caractères")
                .bail(),

            body("email")
                .optional()
                .trim()
                .isEmail()
                .withMessage("Le format du courriel entré est invalide")
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
                    "Le mot de passe doit contenir au moins 8 caractères, avec au moins une lettre minuscule, une lettre majuscule, un chiffre et un symbole"
                )
                .bail(),
        ];
    }
}

export default new UserValidators();
