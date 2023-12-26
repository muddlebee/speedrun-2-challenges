import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "ethers";

const deployStaker: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy, get } = hre.deployments;
  const exampleExternalContract = await get("ExampleExternalContract");

  const threshold = ethers.utils.parseEther("2"); // Set the threshold to 10 ETH
  const deadline = Math.floor(Date.now() / 1000) + 10; // Set the deadline to 10 seconds from now

  await deploy("Staker", {
    from: deployer,
    // Contract constructor arguments
    args: [threshold, deadline, exampleExternalContract.address],
    log: true,
    autoMine: true,
  });
};

export default deployStaker;

deployStaker.tags = ["Staker"];