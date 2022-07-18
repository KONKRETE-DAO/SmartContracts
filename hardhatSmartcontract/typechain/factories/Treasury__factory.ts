/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import { Provider, TransactionRequest } from "@ethersproject/providers";
import type { Treasury, TreasuryInterface } from "../Treasury";

const _abi = [
  {
    inputs: [
      {
        internalType: "contract IERC20",
        name: "_currencyUsed",
        type: "address",
      },
      {
        internalType: "address",
        name: "_pToken",
        type: "address",
      },
      {
        internalType: "address",
        name: "_stakingContract",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "previousOwner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "OwnershipTransferred",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "RentDeposit",
    type: "event",
  },
  {
    inputs: [],
    name: "MAX_TOKEN_SUPPLY",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "claimReward",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "currencyUsed",
    outputs: [
      {
        internalType: "contract IERC20",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "deposit",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "konkreteTreasury",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "owner",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "pToken",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "renounceOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "stakingContract",
    outputs: [
      {
        internalType: "contract IStaking",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "transferOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

const _bytecode =
  "0x6101006040523480156200001257600080fd5b5060405162001188380380620011888339818101604052810190620000389190620002f1565b620000586200004c6200017660201b60201c565b6200017e60201b60201c565b8273ffffffffffffffffffffffffffffffffffffffff1660808173ffffffffffffffffffffffffffffffffffffffff16815250508173ffffffffffffffffffffffffffffffffffffffff1660a08173ffffffffffffffffffffffffffffffffffffffff16815250508073ffffffffffffffffffffffffffffffffffffffff1660c08173ffffffffffffffffffffffffffffffffffffffff16815250508173ffffffffffffffffffffffffffffffffffffffff166332cb6b0c6040518163ffffffff1660e01b8152600401602060405180830381865afa15801562000140573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019062000166919062000388565b60e08181525050505050620003ba565b600033905090565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050816000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a35050565b600080fd5b600073ffffffffffffffffffffffffffffffffffffffff82169050919050565b6000620002748262000247565b9050919050565b6000620002888262000267565b9050919050565b6200029a816200027b565b8114620002a657600080fd5b50565b600081519050620002ba816200028f565b92915050565b620002cb8162000267565b8114620002d757600080fd5b50565b600081519050620002eb81620002c0565b92915050565b6000806000606084860312156200030d576200030c62000242565b5b60006200031d86828701620002a9565b93505060206200033086828701620002da565b92505060406200034386828701620002da565b9150509250925092565b6000819050919050565b62000362816200034d565b81146200036e57600080fd5b50565b600081519050620003828162000357565b92915050565b600060208284031215620003a157620003a062000242565b5b6000620003b18482850162000371565b91505092915050565b60805160a05160c05160e051610d7862000410600039600061051101526000818161025a015281816103e101526105350152600081816101cb015261049d0152600081816101ef01526103030152610d786000f3fe608060405234801561001057600080fd5b506004361061009e5760003560e01c8063b6b55f2511610066578063b6b55f2514610125578063b88a802f14610141578063e489d5101461014b578063ee99205c14610169578063f2fde38b146101875761009e565b80630b7bcb0c146100a357806358a06f07146100c15780635a27d492146100df578063715018a6146100fd5780638da5cb5b14610107575b600080fd5b6100ab6101a3565b6040516100b89190610765565b60405180910390f35b6100c96101c9565b6040516100d69190610765565b60405180910390f35b6100e76101ed565b6040516100f491906107df565b60405180910390f35b610105610211565b005b61010f610225565b60405161011c9190610765565b60405180910390f35b61013f600480360381019061013a919061083f565b61024e565b005b6101496103dd565b005b61015361050f565b604051610160919061087b565b60405180910390f35b610171610533565b60405161017e91906108b7565b60405180910390f35b6101a1600480360381019061019c91906108fe565b610557565b005b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b7f000000000000000000000000000000000000000000000000000000000000000081565b7f000000000000000000000000000000000000000000000000000000000000000081565b6102196105da565b6102236000610658565b565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16905090565b6102566105da565b60007f000000000000000000000000000000000000000000000000000000000000000073ffffffffffffffffffffffffffffffffffffffff1663c26c60de836040518263ffffffff1660e01b81526004016102b1919061087b565b6020604051808303816000875af11580156102d0573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906102f49190610940565b826102ff919061099c565b90507f000000000000000000000000000000000000000000000000000000000000000073ffffffffffffffffffffffffffffffffffffffff166323b872dd3330846040518463ffffffff1660e01b815260040161035e939291906109d0565b6020604051808303816000875af115801561037d573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906103a19190610a3f565b507f43fd4afc08b06749c4d36c42d4a8b46fdcc365da7e2c3fda2a263944b2f88228826040516103d1919061087b565b60405180910390a15050565b60007f000000000000000000000000000000000000000000000000000000000000000090508073ffffffffffffffffffffffffffffffffffffffff16633d1da5cb336040518263ffffffff1660e01b815260040161043b9190610765565b60c0604051808303816000875af115801561045a573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061047e9190610bdd565b508073ffffffffffffffffffffffffffffffffffffffff1663b7f204e27f0000000000000000000000000000000000000000000000000000000000000000336040518363ffffffff1660e01b81526004016104da929190610c0a565b600060405180830381600087803b1580156104f457600080fd5b505af1158015610508573d6000803e3d6000fd5b5050505050565b7f000000000000000000000000000000000000000000000000000000000000000081565b7f000000000000000000000000000000000000000000000000000000000000000081565b61055f6105da565b600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16036105ce576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016105c590610cb6565b60405180910390fd5b6105d781610658565b50565b6105e261071c565b73ffffffffffffffffffffffffffffffffffffffff16610600610225565b73ffffffffffffffffffffffffffffffffffffffff1614610656576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161064d90610d22565b60405180910390fd5b565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050816000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a35050565b600033905090565b600073ffffffffffffffffffffffffffffffffffffffff82169050919050565b600061074f82610724565b9050919050565b61075f81610744565b82525050565b600060208201905061077a6000830184610756565b92915050565b6000819050919050565b60006107a56107a061079b84610724565b610780565b610724565b9050919050565b60006107b78261078a565b9050919050565b60006107c9826107ac565b9050919050565b6107d9816107be565b82525050565b60006020820190506107f460008301846107d0565b92915050565b6000604051905090565b600080fd5b6000819050919050565b61081c81610809565b811461082757600080fd5b50565b60008135905061083981610813565b92915050565b60006020828403121561085557610854610804565b5b60006108638482850161082a565b91505092915050565b61087581610809565b82525050565b6000602082019050610890600083018461086c565b92915050565b60006108a1826107ac565b9050919050565b6108b181610896565b82525050565b60006020820190506108cc60008301846108a8565b92915050565b6108db81610744565b81146108e657600080fd5b50565b6000813590506108f8816108d2565b92915050565b60006020828403121561091457610913610804565b5b6000610922848285016108e9565b91505092915050565b60008151905061093a81610813565b92915050565b60006020828403121561095657610955610804565b5b60006109648482850161092b565b91505092915050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b60006109a782610809565b91506109b283610809565b9250828210156109c5576109c461096d565b5b828203905092915050565b60006060820190506109e56000830186610756565b6109f26020830185610756565b6109ff604083018461086c565b949350505050565b60008115159050919050565b610a1c81610a07565b8114610a2757600080fd5b50565b600081519050610a3981610a13565b92915050565b600060208284031215610a5557610a54610804565b5b6000610a6384828501610a2a565b91505092915050565b600080fd5b6000601f19601f8301169050919050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b610aba82610a71565b810181811067ffffffffffffffff82111715610ad957610ad8610a82565b5b80604052505050565b6000610aec6107fa565b9050610af88282610ab1565b919050565b600067ffffffffffffffff82169050919050565b610b1a81610afd565b8114610b2557600080fd5b50565b600081519050610b3781610b11565b92915050565b600060c08284031215610b5357610b52610a6c565b5b610b5d60c0610ae2565b90506000610b6d84828501610a2a565b6000830152506020610b8184828501610b28565b6020830152506040610b9584828501610b28565b6040830152506060610ba98482850161092b565b6060830152506080610bbd8482850161092b565b60808301525060a0610bd18482850161092b565b60a08301525092915050565b600060c08284031215610bf357610bf2610804565b5b6000610c0184828501610b3d565b91505092915050565b6000604082019050610c1f6000830185610756565b610c2c6020830184610756565b9392505050565b600082825260208201905092915050565b7f4f776e61626c653a206e6577206f776e657220697320746865207a65726f206160008201527f6464726573730000000000000000000000000000000000000000000000000000602082015250565b6000610ca0602683610c33565b9150610cab82610c44565b604082019050919050565b60006020820190508181036000830152610ccf81610c93565b9050919050565b7f4f776e61626c653a2063616c6c6572206973206e6f7420746865206f776e6572600082015250565b6000610d0c602083610c33565b9150610d1782610cd6565b602082019050919050565b60006020820190508181036000830152610d3b81610cff565b905091905056fea2646970667358221220dbbc3146791a1e37f77729987a1c160c3ccbfa926fa67de1ef1b3ec649ed53fb64736f6c634300080e0033";

export class Treasury__factory extends ContractFactory {
  constructor(
    ...args: [signer: Signer] | ConstructorParameters<typeof ContractFactory>
  ) {
    if (args.length === 1) {
      super(_abi, _bytecode, args[0]);
    } else {
      super(...args);
    }
  }

  deploy(
    _currencyUsed: string,
    _pToken: string,
    _stakingContract: string,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<Treasury> {
    return super.deploy(
      _currencyUsed,
      _pToken,
      _stakingContract,
      overrides || {}
    ) as Promise<Treasury>;
  }
  getDeployTransaction(
    _currencyUsed: string,
    _pToken: string,
    _stakingContract: string,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(
      _currencyUsed,
      _pToken,
      _stakingContract,
      overrides || {}
    );
  }
  attach(address: string): Treasury {
    return super.attach(address) as Treasury;
  }
  connect(signer: Signer): Treasury__factory {
    return super.connect(signer) as Treasury__factory;
  }
  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): TreasuryInterface {
    return new utils.Interface(_abi) as TreasuryInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): Treasury {
    return new Contract(address, _abi, signerOrProvider) as Treasury;
  }
}
