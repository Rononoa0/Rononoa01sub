'reach 0.1';
const [isOutcome, WINNER, NOWINNNER] = makeEnum(2)
const winner_func = (num1, num2) => {
  const decision =
    num1 === num2 ? WINNER : NOWINNNER
  return decision
}
assert(winner_func(12, 12) == WINNER)
assert(winner_func(12, 15) == NOWINNNER)
export const main = Reach.App(() => {
  const A = Participant('A', {
    ...hasRandom,
    tokenid: Token,
    winticket: Fun([], UInt),
    See_digest_value: Fun([Digest], Bool),
    ticketmaxnum: Fun([], UInt),
    seeticketnumbers: Fun([UInt], Bool)
  });
  const B = API('B', {
    B_ticknum: Fun([UInt], Null)
  });
  init();

  A.only(() => {
    const gettokenid = declassify(interact.tokenid)
    const ticketmaxnum = declassify(interact.ticketmaxnum())
  })
  A.publish(gettokenid, ticketmaxnum)

  const storagemapping = new Map(Address, UInt)
  //assert(ticketmaxnum == 6)
  const [id, B_tickets, B_address] =
    parallelReduce([0, Array_replicate(6, 0), Array_replicate(6, A)])
      .invariant(balance(gettokenid) == 0 && balance() == 0)
      .while(id < 6)
      .api(
        B.B_ticknum,
        (B_ticket, k) => {
          k(null);
          storagemapping[this] = B_ticket
          return [id + 1, B_tickets.set(id, B_ticket), B_address.set(id, this)]
        }
      )

  commit()
  A.only(() => {
    const _winticket = interact.winticket()
    const [_committwinticket, _saltwinticket] = makeCommitment(interact, _winticket)
    const committwinticket = declassify(_committwinticket)
  })
  A.publish(committwinticket)
  commit()

  A.only(() => {
    const view_num = declassify(interact.See_digest_value(committwinticket))
  })
  A.publish(view_num)
  commit()
  A.only(() => {
    const saltwinticket = declassify(_saltwinticket)
    const winticket = declassify(_winticket)
  })
  A.publish(saltwinticket, winticket)
  checkCommitment(committwinticket, saltwinticket, winticket)
  var [ids, view_tickets, view_address] = [1, B_tickets, B_address]
  invariant(balance(gettokenid) == 0 && balance() == 0)
  while (ids < 7) {
    commit()
    A.publish()
    const [add1, add2, add3, add4, add5, add6] = view_address
    const [ticketnum1, ticketnum2, ticketnum3, ticketnum4, ticketnum5, ticketnum6] = view_tickets
    const address =
      ids == 1 ? add1 :
        ids == 2 ? add2 :
          ids == 3 ? add3 :
            ids == 4 ? add4 :
              ids == 5 ? add5 :
                add6
    const tickets =
      ids == 1 ? ticketnum1 :
        ids == 2 ? ticketnum2 :
          ids == 3 ? ticketnum3 :
            ids == 4 ? ticketnum4 :
              ids == 5 ? ticketnum5 :
                ticketnum6
    commit()
    A.only(() => {
      const seeticket = declassify(interact.seeticketnumbers(tickets))
    })
    A.publish(seeticket)
    const outcome = winner_func(winticket, tickets)
    const amt = 1
    if (outcome == WINNER && seeticket == true) {
      commit()
      A.pay([[amt, gettokenid]])
      transfer([[amt, gettokenid]]).to(address)
      ids = ids + 1
      continue
    } else {
      ids = ids + 1
      continue
    }
  }
  transfer(balance()).to(A)
  commit()
});
