import { MinterTracker } from "../../typechain-types";
import { deployContract } from "../helper";

async function main() {
  await deployContract<MinterTracker>("MinterTracker", [], "MinterTracker", {});
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
