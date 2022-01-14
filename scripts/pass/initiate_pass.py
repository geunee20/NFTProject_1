from brownie import accounts, config, network, nft_dropsV2
from web3 import Web3


FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork", "mainnet-fork-dev"]
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]
OPENSEA_URL = "https://testnets.opensea.io/assets/{}/{}"


def get_account(index=None, id=None):
    if index:
        return accounts[index]
    if id:
        return accounts.load(id)
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return accounts[0]

    return accounts.add(config["wallets"]["from_key"])


def deploy(account, contract):
    account = account if account else get_account()
    contract = contract.deploy(
        0,
        0,
        0,
        0,
        0,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify", False),
    )
    return contract


def main():
    account = get_account()
    contract = deploy(account, nft_dropsV2)
    contract = nft_dropsV2[-1]
    print(f"{contract.address}")
