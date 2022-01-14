from brownie import accounts, config, network, itsSalaryDay
from web3 import Web3

LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["Development", "ganache-local"]


def get_account():
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        return accounts[0]
    return accounts.add(config["wallets"]["from_key"])


def main():
    account = get_account()

    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        address_ganache = [accounts[1], accounts[2], accounts[3], accounts[4]]
    else:
        address_ganache = [
            "0x89dAff76C1F71819455b0ab41dfE77A673780214",
            "0x222116427518A3cb9Ef6E4edEd2049228dDE3638",
            "0xBDc47e2C98f12F1272Ef0be50627eca248e4C288",
            "0xfF948cB7eFD18924a5822F26e1bD0e4F0F9d938b",
        ]
    shares = [40, 30, 20, 10]
    newShares = [10, 20, 30, 40]

    address_rinkeby = [
        "0x2D9371D39E26C2A3785Ac65681390C6187ED23C9",
        "0x7f74D8e6d7EA5881Cab221F83A3f0Bb788C79e57",
        "0x7E536675e95fBBa1979fb0c392Ea9ee54199Fcd7",
        "0x33900Fe22ebc4418E084a6336CA570f116d01EAD",
    ]
    salaries = [500, 400, 300, 200]
    newSalaries = [200, 300, 400, 500]

    contract = itsSalaryDay[-1]
    contract.checkCofounders({"from": account})
    contract.checkMembers({"from": account})

    # -----------------------------------------------------------------------------------------------------------------------------------------
    # contract = itsSalaryDay.deploy(
    #     address_ganache,
    #     shares,
    #     {"from": account},
    # )
    # contract = itsSalaryDay[-1]

    # print(f"{contract.address}")
    # for i in range(contract.numCofounder()):
    #     print(
    #         f"{contract.idxToCof(i)}: {contract.cofToIdx(address_ganache[i])}: {contract.isCof(address_ganache[i])}, {contract.shares(address_ganache[i])}"
    #     )

    # -----------------------------------------------------------------------------------------------------------------------------------------
    # contract = itsSalaryDay.deploy(
    #     address_ganache,
    #     shares,
    #     {"from": account},
    # )
    # contract = itsSalaryDay[-1]
    # print(f"{contract.owner()}")
    # contract.transferOwnership(
    #     "0x2D9371D39E26C2A3785Ac65681390C6187ED23C9",
    #     {"from": account},
    # )
    # print(f"{contract.owner()}")

    # -----------------------------------------------------------------------------------------------------------------------------------------
    # contract = itsSalaryDay.deploy(
    #     address_ganache,
    #     shares,
    #     {"from": account},
    # )
    # contract = itsSalaryDay[-1]
    # for i in range(4):
    #     print(
    #         f"{contract.idxToMem(i)}, {contract.memToIdx(address_ganache[i])}, {contract.isMem(address_ganache[i])}, {contract.salaries(address_ganache[i])}"
    #     )
    # contract.addMembers(address_ganache, salaries, {"from": account})
    # for i in range(4):
    #     print(
    #         f"{contract.idxToMem(i)}, {contract.memToIdx(address_ganache[i])}, {contract.isMem(address_ganache[i])}, {contract.salaries(address_ganache[i])}"
    #     )
    # contract.removeMembers(address_ganache, {"from": account})
    # for i in range(4):
    #     print(
    #         f"{contract.idxToMem(contract.numMember() - 4 + i)}, {contract.memToIdx(address_ganache[contract.numMember() - 4 + i])}, {contract.isMem(address_ganache[contract.numMember() - 4 + i])}, {contract.salaries(address_ganache[contract.numMember() - 4 + i])}"
    #     )

    # contract.addMembers(address_ganache, salaries, {"from": account})
    # for i in range(4):
    #     print(
    #         f"{contract.idxToMem(contract.numMember() - 4 + i)}, {contract.memToIdx(address_ganache[i])}, {contract.isMem(address_ganache[i])}, {contract.salaries(address_ganache[i])}"
    #     )

    # -----------------------------------------------------------------------------------------------------------------------------------------
    # contract = itsSalaryDay.deploy(
    #     address_ganache,
    #     shares,
    #     {"from": account},
    # )
    # contract = itsSalaryDay[-1]
    # contract.addMembers(address_ganache, salaries, {"from": account})
    # for i in range(contract.numMember()):
    #     print(
    #         f"{contract.idxToMem(i)}, {contract.memToIdx(address_ganache[i])}, {contract.isMem(address_ganache[i])}, {contract.salaries(address_ganache[i])}"
    #     )
    # contract.updateSalary(address_ganache, newSalaries, {"from": account})
    # for i in range(contract.numMember()):
    #     print(
    #         f"{contract.idxToMem(i)}, {contract.memToIdx(address_ganache[i])}, {contract.isMem(address_ganache[i])}, {contract.salaries(address_ganache[i])}"
    #     )

    # -----------------------------------------------------------------------------------------------------------------------------------------
    # contract = itsSalaryDay.deploy(
    #     address_ganache,
    #     shares,
    #     {"from": account},
    # )
    # contract = itsSalaryDay[-1]
    # for i in range(contract.numCofounder()):
    #     print(
    #         f"{contract.idxToCof(i)}: {contract.cofToIdx(address_ganache[i])}: {contract.isCof(address_ganache[i])}, {contract.shares(address_ganache[i])}"
    #     )
    # contract.removeCofounder(address_ganache[0])
    # contract.removeCofounder(address_ganache[2])
    # contract.removeCofounder(address_ganache[3])
    # for i in range(4):
    #     print(
    #         f"{contract.idxToCof(i)}: {contract.cofToIdx(address_ganache[i])}: {contract.isCof(address_ganache[i])}, {contract.shares(address_ganache[i])}"
    #     )

    # -----------------------------------------------------------------------------------------------------------------------------------------
    # contract = itsSalaryDay.deploy(
    #     address_ganache,
    #     shares,
    #     {"from": account},
    # )
    # contract = itsSalaryDay[-1]
    # for i in range(contract.numCofounder()):
    #     print(
    #         f"{contract.idxToCof(i)}: {contract.cofToIdx(address_ganache[i])}: {contract.isCof(address_ganache[i])}, {contract.shares(address_ganache[i])}"
    #     )
    # contract.updateShare(address_ganache, newShares)
    # for i in range(contract.numCofounder()):
    #     print(
    #         f"{contract.idxToCof(i)}: {contract.cofToIdx(address_ganache[i])}: {contract.isCof(address_ganache[i])}, {contract.shares(address_ganache[i])}"
    #     )

    # -----------------------------------------------------------------------------------------------------------------------------------------
    # contract = itsSalaryDay.deploy(
    #     address_ganache,
    #     shares,
    #     {"from": account},
    # )
    # contract = itsSalaryDay[-1]
    # contract.transferEthToThisContract(
    #     {"from": account, "value": Web3.toWei(10, "ether")}
    # )
    # contract.transferShare()
    # contract.withdraw({"from": account})

    # -----------------------------------------------------------------------------------------------------------------------------------------
    # contract = itsSalaryDay.deploy(
    #     address_ganache,
    #     shares,
    #     {"from": account},
    # )
    # contract = itsSalaryDay[-1]
    # contract.addMembers(address_rinkeby, salaries, {"from": account})
    # for i in range(contract.numMember()):
    #     print(
    #         f'{address_rinkeby[i]}: {contract.checkSalary({"from": address_rinkeby[i]})}'
    #     )
    # for i in range(contract.numCofounder()):
    #     print(
    #         f'{address_ganache[i]}: {contract.checkSalary({"from": address_ganache[i]})}'
    #     )

    # -----------------------------------------------------------------------------------------------------------------------------------------
    # change cofounders address
    # contract = itsSalaryDay.deploy(
    #     address_ganache,
    #     shares,
    #     {"from": account},
    # )

    # tempAccounts = [
    #     accounts[5],
    #     accounts[6],
    #     accounts[7],
    #     accounts[8],
    # ]

    # contract = itsSalaryDay[-1]
    # for i in range(4):
    #     print(
    #         f"{contract.idxToCof(i)}: {contract.cofToIdx(address_ganache[i])}: {contract.isCof(address_ganache[i])}, {contract.shares(address_ganache[i])}"
    #     )
    # for i in range(4):
    #     print(
    #         f"{tempAccounts[i]}: {contract.cofToIdx(tempAccounts[i])}: {contract.isCof(tempAccounts[i])}, {contract.shares(tempAccounts[i])}"
    #     )

    # for i in range(4):
    #     contract.changeWallet(tempAccounts[i], {"from": address_ganache[i]})

    # for i in range(4):
    #     print(
    #         f"{address_ganache[i]}: {contract.cofToIdx(address_ganache[i])}: {contract.isCof(address_ganache[i])}, {contract.shares(address_ganache[i])}"
    #     )
    # for i in range(4):
    #     print(
    #         f"{contract.idxToCof(i)}: {contract.cofToIdx(tempAccounts[i])}: {contract.isCof(tempAccounts[i])}, {contract.shares(tempAccounts[i])}"
    #     )

    # contract.transferEthToThisContract(
    #     {"from": account, "value": Web3.toWei(10, "ether")}
    # )
    # contract.transferShare()
    # contract.withdraw({"from": account})

    # -----------------------------------------------------------------------------------------------------------------------------------------
    # change members address
    # contract = itsSalaryDay.deploy(
    #     [
    #         "0x43B2b8f7841b620cF48d0C7e53742c86c45B95aE",
    #         "0x43B2b8f7841b620cF48d0C7e53742c86c45B95aE",
    #         "0x43B2b8f7841b620cF48d0C7e53742c86c45B95aE",
    #         "0x43B2b8f7841b620cF48d0C7e53742c86c45B95aE",
    #     ],
    #     shares,
    #     {"from": account},
    #     publish_source=config["networks"][network.show_active()].get("verify", False),
    # )

    # temp1 = [address_rinkeby[0], address_rinkeby[1]]
    # print(f"{contract.address}")
    # contract.addMembers(temp1, [salaries[0], salaries[1]], {"from": account})
    # contract = itsSalaryDay[-1]

    # need to move etherscan and check by hand

    # -----------------------------------------------------------------------------------------------------------------------------------------
    # contract = itsSalaryDay.deploy(
    #     address_rinkeby,
    #     shares,
    #     {"from": account},
    # )
    # contract = itsSalaryDay[-1]
    # contract.transferEthToThisContract(
    #     {"from": account, "value": Web3.toWei(1, "ether")}
    # )
    # contract.addMembers(address_rinkeby, salaries, {"from": account})
    # for i in range(contract.numMember()):
    #     print(
    #         f"{contract.idxToMem(i)}, {contract.memToIdx(address_rinkeby[i])}, {contract.isMem(address_rinkeby[i])}, {contract.salaries(address_rinkeby[i])}"
    #     )
    # contract.transferSalary({"from": account})
    # contract.withdraw({"from": account})
