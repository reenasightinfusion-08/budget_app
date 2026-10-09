const isWholeNumber = { validator: Number.isInteger, message: '{PATH} must be a whole number' };

const DAY = /^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/;
const MONTH = /^\d{4}-(0[1-9]|1[0-2])$/;

module.exports = { isWholeNumber, DAY, MONTH };
