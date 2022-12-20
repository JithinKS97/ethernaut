import hardhat from "hardhat";
import DEPLOY_DATA from "../../client/src/gamedata/deploy.goerli.json" assert { type:"json" }

const { ethers } = hardhat;

const upgradeProxy = async () => { 
    const newStatisticsContractAddress = await deployStatistics();
    const proxyAdmin = await getProxyAdmin()
    const admin = await getImpersonatedSigner("0x09902A56d04a9446601a0d451E07459dC5aF0820")
    const result = await proxyAdmin
        .connect(admin)
        .upgrade(DEPLOY_DATA.proxyStats, newStatisticsContractAddress);
    console.log("Upgraded")
}

const deployStatistics = async () => { 
    const Statistics = await ethers.getContractFactory("Statistics");
    const statistics = await Statistics.deploy();
    return statistics.address;
}

const getProxyAdmin = async () => { 
    const ProxyAdmin = await ethers.getContractFactory("ProxyAdmin");
    const contract = await ProxyAdmin.attach(
        DEPLOY_DATA.proxyAdmin
    );
    return contract;
}

const getImpersonatedSigner = async (address) => { 
    const impersonatedSigner = await ethers.getImpersonatedSigner(address);
    return impersonatedSigner;
}

upgradeProxy()