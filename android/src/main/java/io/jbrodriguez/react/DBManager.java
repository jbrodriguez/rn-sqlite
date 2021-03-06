package io.jbrodriguez.react;

import javax.annotation.Nullable;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteStatement;

import com.facebook.common.logging.FLog;
import com.facebook.infer.annotation.Assertions;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.GuardedAsyncTask;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.ReactConstants;
// import com.facebook.react.modules.common.ModuleDataCleaner;

import io.jbrodriguez.react.SQLiteManager;

// public final class DBManager extends ReactContextBaseJavaModule implements ModuleDataCleaner.Cleanable {

public final class DBManager extends ReactContextBaseJavaModule {
	private @Nullable SQLiteManager mDb;
	private boolean mShuttingDown = false;

	public DBManager(ReactApplicationContext reactContext) {
		super(reactContext);
	}

	@Override
	public String getName() {
		return "DBManager";
	}

	@Override
	public void initialize() {
		super.initialize();
		mShuttingDown = false;
	}

	@Override
	public void onCatalystInstanceDestroy() {
		mShuttingDown = true;
		if (mDb != null && mDb.isOpen()) {
			mDb.close();
			mDb = null;
		}
	}	

	@ReactMethod
	public void init(final String name, final Callback callback) {
		new GuardedAsyncTask<Void, Void>(getReactApplicationContext()) {
			@Override
			protected void doInBackgroundGuarded(Void ...params) {
				// FLog.w(ReactConstants.TAG, "dbmanager.init.name=%s", name);
				mDb = new SQLiteManager(getReactApplicationContext(), name);
				mDb.init();
				callback.invoke();
			}
		}.execute();
	}

	@ReactMethod
	public void query(final String sql, final ReadableArray values, final Callback callback) {
		new GuardedAsyncTask<Void, Void>(getReactApplicationContext()) {
			@Override
			protected void doInBackgroundGuarded(Void ...params) {
				WritableArray data = Arguments.createArray();
				WritableMap error = null;
				// FLog.w(ReactConstants.TAG, "dbmanager.query.sql=%s", sql);
				// FLog.w(ReactConstants.TAG, "dbmanager.query.values.size()=%d", values.size());

				try {
					data = mDb.query(sql, values);
				} catch(Exception e) {
					FLog.w(ReactConstants.TAG, "Exception in database query: ", e);
					error = ErrorUtil.getError(null, e.getMessage());
				}

				if (error != null) {
					callback.invoke(error, null);
				} else {
					callback.invoke(null, data);
				}
			}
		}.execute();
	}

	@ReactMethod
	public void exec(final String sql, final ReadableArray values, final Callback callback) {
		new GuardedAsyncTask<Void, Void>(getReactApplicationContext()) {
			@Override
			protected void doInBackgroundGuarded(Void ...params) {
				WritableMap error = null;

				try {
					mDb.exec(sql, values);
				} catch(Exception e) {
					FLog.w(ReactConstants.TAG, "Exception in database exec: ", e);
					error = ErrorUtil.getError(null, e.getMessage());
				}

				if (error != null) {
					callback.invoke(error, null);
				} else {
					callback.invoke();
				}
			}
		}.execute();
	}

	@ReactMethod
	public void close(final Callback callback) {
		new GuardedAsyncTask<Void, Void>(getReactApplicationContext()) {
			@Override
			protected void doInBackgroundGuarded(Void ...params) {
				WritableMap error = null;

				try {
					mDb.close();
				} catch(Exception e) {
					FLog.w(ReactConstants.TAG, "Exception in database close: ", e);
					error = ErrorUtil.getError(null, e.getMessage());
				}

				if (error != null) {
					callback.invoke(error, null);
				} else {
					callback.invoke();
				}
			}
		}.execute();
	}	
}
