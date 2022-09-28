local secrets = std.extVar('secrets');

{
  someSecretString: secrets.secretString,
  someSecretObject: secrets.secretObject,
}
