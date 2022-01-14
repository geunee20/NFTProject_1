from brownie import RVNShare, accounts, config


def get_account():
    return accounts.add(config["wallets"]["from_key"])


def main():
    account = get_account()
    contract = RVNShare[-1]
    contract.withdraw({"from": account})
    # contract.split({"from": account})
