package com.Utils.PullRefreshListView.extras;

import java.util.HashMap;

import com.Utils.PullRefreshListView.PullToRefreshBase;
import com.Utils.PullRefreshListView.PullToRefreshBase.Mode;
import com.Utils.PullRefreshListView.PullToRefreshBase.State;

import android.content.Context;
import android.media.MediaPlayer;
import android.view.View;


public class SoundPullEventListener<V extends View> implements PullToRefreshBase.OnPullEventListener<V> {

	private final Context mContext;
	private final HashMap<State, Integer> mSoundMap;

	private MediaPlayer mCurrentMediaPlayer;

	public SoundPullEventListener(Context context) {
		mContext = context;
		mSoundMap = new HashMap<State, Integer>();
	}

	@Override
	public final void onPullEvent(PullToRefreshBase<V> refreshView, State event, Mode direction) {
		Integer soundResIdObj = mSoundMap.get(event);
		if (null != soundResIdObj) {
			playSound(soundResIdObj.intValue());
		}
	}
	
	public void addSoundEvent(State event, int resId) {
		mSoundMap.put(event, resId);
	}

	public void clearSounds() {
		mSoundMap.clear();
	}

	public MediaPlayer getCurrentMediaPlayer() {
		return mCurrentMediaPlayer;
	}

	private void playSound(int resId) {
		// Stop current player, if there's one playing
		if (null != mCurrentMediaPlayer) {
			mCurrentMediaPlayer.stop();
			mCurrentMediaPlayer.release();
		}

		mCurrentMediaPlayer = MediaPlayer.create(mContext, resId);
		if (null != mCurrentMediaPlayer) {
			mCurrentMediaPlayer.start();
		}
	}

}
