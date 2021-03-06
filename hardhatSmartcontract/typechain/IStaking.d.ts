/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import {
  ethers,
  EventFilter,
  Signer,
  BigNumber,
  BigNumberish,
  PopulatedTransaction,
  BaseContract,
  ContractTransaction,
  Overrides,
  CallOverrides,
} from "ethers";
import { BytesLike } from "@ethersproject/bytes";
import { Listener, Provider } from "@ethersproject/providers";
import { FunctionFragment, EventFragment, Result } from "@ethersproject/abi";
import type { TypedEventFilter, TypedEvent, TypedListener } from "./common";

interface IStakingInterface extends ethers.utils.Interface {
  functions: {
    "TOKEN_TO_STAKE()": FunctionFragment;
    "TOKEN_TO_STAKE_MAX_SUPPLY()": FunctionFragment;
    "beginTimestamp()": FunctionFragment;
    "getStakeInfos(address)": FunctionFragment;
    "resetClaimableReward(address,address)": FunctionFragment;
    "setTotalClaimableReward(uint256)": FunctionFragment;
    "stake(uint256)": FunctionFragment;
    "stakeByOwner(address)": FunctionFragment;
    "unStake(uint256)": FunctionFragment;
  };

  encodeFunctionData(
    functionFragment: "TOKEN_TO_STAKE",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "TOKEN_TO_STAKE_MAX_SUPPLY",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "beginTimestamp",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "getStakeInfos",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "resetClaimableReward",
    values: [string, string]
  ): string;
  encodeFunctionData(
    functionFragment: "setTotalClaimableReward",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(functionFragment: "stake", values: [BigNumberish]): string;
  encodeFunctionData(
    functionFragment: "stakeByOwner",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "unStake",
    values: [BigNumberish]
  ): string;

  decodeFunctionResult(
    functionFragment: "TOKEN_TO_STAKE",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "TOKEN_TO_STAKE_MAX_SUPPLY",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "beginTimestamp",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getStakeInfos",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "resetClaimableReward",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setTotalClaimableReward",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "stake", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "stakeByOwner",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "unStake", data: BytesLike): Result;

  events: {};
}

export class IStaking extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  listeners<EventArgsArray extends Array<any>, EventArgsObject>(
    eventFilter?: TypedEventFilter<EventArgsArray, EventArgsObject>
  ): Array<TypedListener<EventArgsArray, EventArgsObject>>;
  off<EventArgsArray extends Array<any>, EventArgsObject>(
    eventFilter: TypedEventFilter<EventArgsArray, EventArgsObject>,
    listener: TypedListener<EventArgsArray, EventArgsObject>
  ): this;
  on<EventArgsArray extends Array<any>, EventArgsObject>(
    eventFilter: TypedEventFilter<EventArgsArray, EventArgsObject>,
    listener: TypedListener<EventArgsArray, EventArgsObject>
  ): this;
  once<EventArgsArray extends Array<any>, EventArgsObject>(
    eventFilter: TypedEventFilter<EventArgsArray, EventArgsObject>,
    listener: TypedListener<EventArgsArray, EventArgsObject>
  ): this;
  removeListener<EventArgsArray extends Array<any>, EventArgsObject>(
    eventFilter: TypedEventFilter<EventArgsArray, EventArgsObject>,
    listener: TypedListener<EventArgsArray, EventArgsObject>
  ): this;
  removeAllListeners<EventArgsArray extends Array<any>, EventArgsObject>(
    eventFilter: TypedEventFilter<EventArgsArray, EventArgsObject>
  ): this;

  listeners(eventName?: string): Array<Listener>;
  off(eventName: string, listener: Listener): this;
  on(eventName: string, listener: Listener): this;
  once(eventName: string, listener: Listener): this;
  removeListener(eventName: string, listener: Listener): this;
  removeAllListeners(eventName?: string): this;

  queryFilter<EventArgsArray extends Array<any>, EventArgsObject>(
    event: TypedEventFilter<EventArgsArray, EventArgsObject>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TypedEvent<EventArgsArray & EventArgsObject>>>;

  interface: IStakingInterface;

  functions: {
    TOKEN_TO_STAKE(overrides?: CallOverrides): Promise<[string]>;

    TOKEN_TO_STAKE_MAX_SUPPLY(overrides?: CallOverrides): Promise<[BigNumber]>;

    beginTimestamp(
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    getStakeInfos(
      tokenHolder: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    resetClaimableReward(
      token: string,
      staker: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    setTotalClaimableReward(
      totalReward: BigNumberish,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    stake(
      amount: BigNumberish,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    stakeByOwner(
      owner: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    unStake(
      amount: BigNumberish,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;
  };

  TOKEN_TO_STAKE(overrides?: CallOverrides): Promise<string>;

  TOKEN_TO_STAKE_MAX_SUPPLY(overrides?: CallOverrides): Promise<BigNumber>;

  beginTimestamp(
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  getStakeInfos(
    tokenHolder: string,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  resetClaimableReward(
    token: string,
    staker: string,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  setTotalClaimableReward(
    totalReward: BigNumberish,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  stake(
    amount: BigNumberish,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  stakeByOwner(
    owner: string,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  unStake(
    amount: BigNumberish,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  callStatic: {
    TOKEN_TO_STAKE(overrides?: CallOverrides): Promise<string>;

    TOKEN_TO_STAKE_MAX_SUPPLY(overrides?: CallOverrides): Promise<BigNumber>;

    beginTimestamp(overrides?: CallOverrides): Promise<void>;

    getStakeInfos(
      tokenHolder: string,
      overrides?: CallOverrides
    ): Promise<void>;

    resetClaimableReward(
      token: string,
      staker: string,
      overrides?: CallOverrides
    ): Promise<void>;

    setTotalClaimableReward(
      totalReward: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    stake(amount: BigNumberish, overrides?: CallOverrides): Promise<void>;

    stakeByOwner(
      owner: string,
      overrides?: CallOverrides
    ): Promise<
      [boolean, BigNumber, BigNumber, BigNumber, BigNumber, BigNumber] & {
        exist: boolean;
        rank: BigNumber;
        lastTimeStamp: BigNumber;
        preShare: BigNumber;
        amount: BigNumber;
        claimableReward: BigNumber;
      }
    >;

    unStake(amount: BigNumberish, overrides?: CallOverrides): Promise<void>;
  };

  filters: {};

  estimateGas: {
    TOKEN_TO_STAKE(overrides?: CallOverrides): Promise<BigNumber>;

    TOKEN_TO_STAKE_MAX_SUPPLY(overrides?: CallOverrides): Promise<BigNumber>;

    beginTimestamp(
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;

    getStakeInfos(
      tokenHolder: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;

    resetClaimableReward(
      token: string,
      staker: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;

    setTotalClaimableReward(
      totalReward: BigNumberish,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;

    stake(
      amount: BigNumberish,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;

    stakeByOwner(
      owner: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;

    unStake(
      amount: BigNumberish,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    TOKEN_TO_STAKE(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    TOKEN_TO_STAKE_MAX_SUPPLY(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    beginTimestamp(
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;

    getStakeInfos(
      tokenHolder: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;

    resetClaimableReward(
      token: string,
      staker: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;

    setTotalClaimableReward(
      totalReward: BigNumberish,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;

    stake(
      amount: BigNumberish,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;

    stakeByOwner(
      owner: string,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;

    unStake(
      amount: BigNumberish,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;
  };
}
