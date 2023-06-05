package app

import (
	banktypes "github.com/cosmos/cosmos-sdk/x/bank/types"
	distrtypes "github.com/cosmos/cosmos-sdk/x/distribution/types"
	govtypes "github.com/cosmos/cosmos-sdk/x/gov/types"
	"github.com/cosmos/cosmos-sdk/x/params/types/proposal"
	stakingtypes "github.com/cosmos/cosmos-sdk/x/staking/types"
	icahosttypes "github.com/cosmos/ibc-go/v4/modules/apps/27-interchain-accounts/host/types"

	upgradetypes "github.com/cosmos/cosmos-sdk/x/upgrade/types"
)

type ParamChangeKey struct {
	MsgType string
	Key     string
}

func IsProposalWhitelisted(content govtypes.Content) bool {
	switch c := content.(type) {
	case *proposal.ParameterChangeProposal:
		return isParamChangeWhitelisted(getParamChangesMapFromArray(c.Changes))
	case *upgradetypes.SoftwareUpgradeProposal,
		*upgradetypes.CancelSoftwareUpgradeProposal:
		return true

	default:
		return false
	}
}

func getParamChangesMapFromArray(paramChanges []proposal.ParamChange) map[ParamChangeKey]struct{} {
	res := map[ParamChangeKey]struct{}{}
	for _, paramChange := range paramChanges {
		key := ParamChangeKey{
			MsgType: paramChange.Subspace,
			Key:     paramChange.Key,
		}

		res[key] = struct{}{}
	}

	return res
}

func isParamChangeWhitelisted(paramChanges map[ParamChangeKey]struct{}) bool {
	for paramChangeKey, _ := range paramChanges {
		_, found := WhitelistedParams[paramChangeKey]
		if !found {
			return false
		}
	}
	return true
}

var WhitelistedParams = map[ParamChangeKey]struct{}{
	// bank
	{MsgType: banktypes.ModuleName, Key: string(banktypes.KeySendEnabled)}: {},
	// governance
	// {MsgType: govtypes.ModuleName, Key: string(govtypes.ParamStoreKeyDepositParams)}: {}, //min_deposit, max_deposit_period
	// {MsgType: govtypes.ModuleName, Key: string(govtypes.ParamStoreKeyVotingParams)}:  {}, //voting_period
	// {MsgType: govtypes.ModuleName, Key: string(govtypes.ParamStoreKeyTallyParams)}:   {}, //quorum,threshold,veto_threshold
	// staking
	{MsgType: stakingtypes.ModuleName, Key: string(stakingtypes.KeyUnbondingTime)}:     {},
	{MsgType: stakingtypes.ModuleName, Key: string(stakingtypes.KeyMaxValidators)}:     {},
	{MsgType: stakingtypes.ModuleName, Key: string(stakingtypes.KeyMaxEntries)}:        {},
	{MsgType: stakingtypes.ModuleName, Key: string(stakingtypes.KeyHistoricalEntries)}: {},
	{MsgType: stakingtypes.ModuleName, Key: string(stakingtypes.KeyBondDenom)}:         {},
	// distribution
	{MsgType: distrtypes.ModuleName, Key: string(distrtypes.ParamStoreKeyCommunityTax)}: {},
	// {MsgType: distrtypes.ModuleName, Key: string(distrtypes.ParamStoreKeyBaseProposerReward)}:  {},
	// {MsgType: distrtypes.ModuleName, Key: string(distrtypes.ParamStoreKeyBonusProposerReward)}: {},
	{MsgType: distrtypes.ModuleName, Key: string(distrtypes.ParamStoreKeyWithdrawAddrEnabled)}: {},
	// ica
	{MsgType: icahosttypes.SubModuleName, Key: string(icahosttypes.KeyHostEnabled)}:   {},
	{MsgType: icahosttypes.SubModuleName, Key: string(icahosttypes.KeyAllowMessages)}: {},
}
