import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
import { ask } from '@reach-sh/stdlib/ask.mjs';


const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(100);
const accA = await stdlib.newTestAccount(startingBalance)
const [B1, B2, B3, B4, B5, B6] = await stdlib.newTestAccounts(6, startingBalance);
const Zunny = await stdlib.launchToken(accA, "zunny", "zunny1", { supply: 1 });

const ctcA = accA.contract(backend);


const B_API_func = async (acct, ticketnumber) => {
  try {
    const ctc = acct.contract(backend, ctcA.getInfo());
    const t = parseInt(ticketnumber)
    acct.tokenAccept(Zunny.id)
    await ctc.apis.B.B_ticknum(parseInt(t));
  } catch (error) {
    console.log(error);
  }

}
const getBalance = async (acct, name) => {
  const amtNFT = await stdlib.balanceOf(acct, Zunny.id);
  console.log(`${name} has ${amtNFT} of the NFT`);
};

console.log('Starting backends...');
await getBalance(accA, 'Alice')
await getBalance(B1, 'Bobs1')
await getBalance(B2, 'Bobs2')
await getBalance(B3, 'Bobs3')
await getBalance(B4, 'Bobs4')
await getBalance(B5, 'Bobs5')
await getBalance(B6, 'Bobs6')
const number = await ask(`what's the winnning ticket Deployer `)
const A_funcs = {
  tokenid: Zunny.id,
  winticket: async () => {
    return parseInt(number)
  },
  See_digest_value: async (digest) => {
    console.log(`hash value: ${digest}`)
    return true
  },
  ticketmaxnum: async () => {
    const ticketmaxnum = 6
    console.log(`Ticketmaxnum entry is ${ticketmaxnum}`)
    return parseInt(ticketmaxnum)
  },
  seeticketnumbers: async (num) => {
    console.log(`Deployer saw ticket ${num}`)
    if (parseInt(num) == parseInt(number)) {
      return true
    } else {
      return false
    }
  },
}
await Promise.all([
  ctcA.p.A({
    ...stdlib.hasRandom,
    ...A_funcs
  }),
  await B_API_func(B1, 23),
  await B_API_func(B2, 16),
  await B_API_func(B3, 15),
  await B_API_func(B4, 24),
  await B_API_func(B5, 65),
  await B_API_func(B6, 1),
]);
await getBalance(accA, 'Alice')
await getBalance(B1, 'Bobs1')
await getBalance(B2, 'Bobs2')
await getBalance(B3, 'Bobs3')
await getBalance(B4, 'Bobs4')
await getBalance(B5, 'Bobs5')
await getBalance(B6, 'Bobs6')
process.exit()
