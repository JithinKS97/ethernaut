import hardhat from "hardhat";
import DEPLOY_DATA from "../../client/src/gamedata/deploy.goerli.json" assert { type:"json" }

const { ethers } = hardhat;


const getStatistics = async () => { 
    const Statistics = await ethers.getContractFactory("Statistics");
    const statistics = await Statistics.attach(DEPLOY_DATA.proxyStats)
    return statistics
}

const readEvent = async () => { 
    const statistics = await getStatistics()
    var provider = new ethers.providers.JsonRpcProvider("http://localhost:8545")
    var abi = [
        "event playerScoreProfile(address,uint256,uint256)"
     ]
    provider.getBlockNumber().then(function(x) {
        statistics.queryFilter([statistics.filters.playerScoreProfile()], x-48, x).then(function(el) {
            console.log(el)
        })
    })
}

readEvent()