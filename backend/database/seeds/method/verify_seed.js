const verifySeed = async (knex, seedName) => {
  return await knex("seeds").where("name", seedName).first();
};

const addSeed = async (knex, seedName) => {
  await knex("seeds").insert({ name: seedName });
};

module.exports = { addSeed, verifySeed };
