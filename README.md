StackFund Smart Contract

Overview
The **StackFund Smart Contract** is a decentralized crowdfunding platform built on the **Stacks blockchain** using Clarity.  
It allows project creators to launch fundraising campaigns, accept contributions in STX, and securely manage funds with transparent, on-chain logic.

StackFund ensures that contributors’ funds are safe, with automatic refunds if campaign goals are not met within the set deadline.

---

 Features
-  **Create Campaigns** — Define a funding goal, description, and deadline.
-  **Contribute in STX** — Support campaigns directly from your wallet.
-  **Transparency** — Query campaign details and status on-chain.
-  **Automatic Refunds** — Contributors get their funds back if the campaign fails.
-  **Secure Withdrawals** — Campaign owners can withdraw only when goals are met.

---

 How It Works
1. **Campaign Creation** — A user sets up a campaign with a goal and deadline.
2. **Funding Period** — Contributors send STX to the campaign.
3. **Goal Check** —  
   - If the goal is met **before the deadline**, the campaign owner can withdraw funds.  
   - If the goal is **not met**, contributors can claim refunds.
4. **Transparency** — All campaign data is stored and queryable on-chain.

---

 Smart Contract Functions
| Function | Description |
|----------|-------------|
| `create-campaign` | Creates a new fundraising campaign. |
| `contribute` | Sends STX to a campaign. |
| `withdraw` | Allows campaign owner to withdraw if goal is met. |
| `refund` | Allows contributors to reclaim funds if goal not met. |
| `get-campaign` | Retrieves campaign details. |

---

 Technical Details
- **Language:** Clarity  
- **Network:** Stacks Blockchain  
- **Token Type:** STX (native token)  
- **State Management:**  
  - Data maps for campaigns and contributions  
  - Goal and deadline enforcement via smart contract logic

---

 Deployment
1. Install [Clarinet](https://github.com/hirosystems/clarinet).
2. Clone this repository:
   ```bash
   git clone https://github.com/your-username/stackfund.git
   cd stackfund
   ;; Create a campaign

Example Usage
(create-campaign u1000000 "Community Solar Project" u1680000000)

;; Contribute to a campaign
(contribute u1 u500000)

;; Withdraw funds (if goal met)
(withdraw u1)

