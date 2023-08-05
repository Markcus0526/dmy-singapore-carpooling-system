using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CarPoolService
{
	public enum AgreeState
	{
		OPPO_NOREPLY,
		OPPO_AGREE,
		OPPO_DISAGREE,
	}

	public enum OffOrder
	{
		OFF_FIRST,
		OFF_LAST,
	}

	public enum UserState
	{
		USERSTATE_REQUEST,
		USERSTATE_RESPONSE,
		USERSTATE_PAIR_SUCCESS,
		USERSTATE_PAIR_FAILURE,
	}
}