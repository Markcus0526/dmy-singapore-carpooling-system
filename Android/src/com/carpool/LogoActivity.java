package com.carpool;

import java.lang.reflect.Method;
import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.Display;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.ViewFlipper;

public class LogoActivity extends Activity implements View.OnTouchListener {
	
	private ViewFlipper flipper;
	private ImageView imgBalloon1;
	private ImageView imgBalloon2;
	private ImageView imgBalloon3;
	private ImageView imgBalloon4;
	private ImageView imgBalloon5;
	private ImageView imgBalloon6;	
    
    float xAtDown;
    float xAtUp;
    
    int nCurPos = 0;
	
	@SuppressWarnings("deprecation")
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.logo);
		
		imgBalloon1 = (ImageView) findViewById(R.id.imgBalloon1);
		imgBalloon2 = (ImageView) findViewById(R.id.imgBalloon2);
		imgBalloon3 = (ImageView) findViewById(R.id.imgBalloon3);
		imgBalloon4 = (ImageView) findViewById(R.id.imgBalloon4);
		imgBalloon5 = (ImageView) findViewById(R.id.imgBalloon5);
		imgBalloon6 = (ImageView) findViewById(R.id.imgBalloon6);		
		
		flipper = (ViewFlipper)findViewById(R.id.viewLogo_Back);
        flipper.setOnTouchListener(this);
        
        WindowManager winManager = (WindowManager) getSystemService(WINDOW_SERVICE);
        Display display = winManager.getDefaultDisplay();
        int nWidth = display.getWidth(), nHeight = display.getHeight();
        
       	int result = getStatusBarHeight();
       	
       	ResolutionSet._instance.setResolution(nWidth, nHeight - result);
       	ResolutionSet._instance.iterateChild(findViewById(R.id.llLogoBack));
	}
	
	public int getStatusBarHeight()
	 {
	        int statusBarHeight = 0;

	        if (!hasOnScreenSystemBar()) {
	            int resourceId = getResources().getIdentifier("status_bar_height", "dimen", "android");
	            if (resourceId > 0) {
	                statusBarHeight = getResources().getDimensionPixelSize(resourceId);
	            }
	        }

	        return statusBarHeight;
	    }
	
	private boolean hasOnScreenSystemBar()
	{
    	Display display = getWindowManager().getDefaultDisplay();
    	int rawDisplayHeight = 0;
    	try {
        	Method getRawHeight = Display.class.getMethod("getRawHeight");
        	rawDisplayHeight = (Integer) getRawHeight.invoke(display);
    	} catch (Exception ex) {}

    	@SuppressWarnings("deprecation")
    	int UIRequestedHeight = display.getHeight();

    	return rawDisplayHeight - UIRequestedHeight > 0;
	}
	
	@Override
	public boolean onTouch(View v, MotionEvent event) {
		if(v != flipper) 
			return false;		
		
		if(event.getAction() == MotionEvent.ACTION_DOWN) {
			xAtDown = event.getX();			
		}
		else if(event.getAction() == MotionEvent.ACTION_UP){
			xAtUp = event.getX();
			
			if( xAtUp < xAtDown ) {
				flipper.setInAnimation(AnimationUtils.loadAnimation(this,
		        		R.anim.right_in));
		        flipper.setOutAnimation(AnimationUtils.loadAnimation(this,
		        		R.anim.left_out));

		        if (nCurPos >= 5)
		        {
		        	SharedPreferences pref = getSharedPreferences(GlobalData.g_SharedPreferencesName, MODE_PRIVATE);
					SharedPreferences.Editor editor = pref.edit();
					editor.putBoolean(GlobalData.g_SharedPreferencesIntro, false);
					editor.commit();
					
					Intent intent = new Intent(LogoActivity.this, SelectPositionActivity.class);
					startActivity(intent);
					LogoActivity.this.finish();
		        }
		        
		        if (nCurPos < 5 )
		        {
		        	nCurPos++;
		        	flipper.showNext();
		        }		        
			}
			else if (xAtUp > xAtDown){
				flipper.setInAnimation(AnimationUtils.loadAnimation(this,
		        		R.anim.left_in));
		        flipper.setOutAnimation(AnimationUtils.loadAnimation(this,
		        		R.anim.right_out));
		        if (nCurPos > 0)
		        {
		        	nCurPos--;
		        	flipper.showPrevious();
		        }
			}
			
			switch (nCurPos)
			{
			case 0:
				imgBalloon1.setImageResource(R.drawable.redballoon);
				imgBalloon2.setImageResource(R.drawable.grayballoon);
				imgBalloon3.setImageResource(R.drawable.grayballoon);
				imgBalloon4.setImageResource(R.drawable.grayballoon);
				imgBalloon5.setImageResource(R.drawable.grayballoon);
				imgBalloon6.setImageResource(R.drawable.grayballoon);
				break;
			case 1:
				imgBalloon1.setImageResource(R.drawable.grayballoon);
				imgBalloon2.setImageResource(R.drawable.redballoon);
				imgBalloon3.setImageResource(R.drawable.grayballoon);
				imgBalloon4.setImageResource(R.drawable.grayballoon);
				imgBalloon5.setImageResource(R.drawable.grayballoon);
				imgBalloon6.setImageResource(R.drawable.grayballoon);
				break;
			case 2:
				imgBalloon1.setImageResource(R.drawable.grayballoon);
				imgBalloon2.setImageResource(R.drawable.grayballoon);
				imgBalloon3.setImageResource(R.drawable.redballoon);
				imgBalloon4.setImageResource(R.drawable.grayballoon);
				imgBalloon5.setImageResource(R.drawable.grayballoon);
				imgBalloon6.setImageResource(R.drawable.grayballoon);
				break;
			case 3:
				imgBalloon1.setImageResource(R.drawable.grayballoon);
				imgBalloon2.setImageResource(R.drawable.grayballoon);
				imgBalloon3.setImageResource(R.drawable.grayballoon);
				imgBalloon4.setImageResource(R.drawable.redballoon);
				imgBalloon5.setImageResource(R.drawable.grayballoon);
				imgBalloon6.setImageResource(R.drawable.grayballoon);
				break;
			case 4:
				imgBalloon1.setImageResource(R.drawable.grayballoon);
				imgBalloon2.setImageResource(R.drawable.grayballoon);
				imgBalloon3.setImageResource(R.drawable.grayballoon);
				imgBalloon4.setImageResource(R.drawable.grayballoon);
				imgBalloon5.setImageResource(R.drawable.redballoon);
				imgBalloon6.setImageResource(R.drawable.grayballoon);
				break;
			case 5:
				imgBalloon1.setImageResource(R.drawable.grayballoon);
				imgBalloon2.setImageResource(R.drawable.grayballoon);
				imgBalloon3.setImageResource(R.drawable.grayballoon);
				imgBalloon4.setImageResource(R.drawable.grayballoon);
				imgBalloon5.setImageResource(R.drawable.grayballoon);
				imgBalloon6.setImageResource(R.drawable.redballoon);
				break;
			}
		}		
		return true;
	}
}
