// Deterministic agent/tool fixture. It never contacts a payment provider.
async function runRefundAgent(request) {
 const events = [{type: "request", amount: request.amount}];
 if (!request.approved) return {status: "approval_required", events}; // APPROVAL_GUARD
 events.push({type: "approval", approvedBy: "reviewed-human-fixture"});
 // This is an executed local tool, with a recorded synthetic side effect.
 const issueRefund = amount => {
  events.push({type: "tool", name: "issue_refund", amount});
  return {status: "refunded", amount, events};
 };
 return issueRefund(request.amount);
}
module.exports = {runRefundAgent};
