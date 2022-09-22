package unic.cicoco.flutter_obs_client_plugin;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;

import com.obs.services.ObsClient;
import com.obs.services.model.PutObjectResult;
import com.wesine.library.common.utils.FileHelper;
import com.wesine.library.common.utils.StreamUtils;

import java.io.File;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * FlutterObsClientPlugin
 */
public class FlutterObsClientPlugin implements FlutterPlugin, Message.ObsClientAPI {

    private static final String TAG = "FlutterObsClientPlugin";
    private Context applicationContext;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        applicationContext = flutterPluginBinding.getApplicationContext();
        Message.ObsClientAPI.setup(flutterPluginBinding.getBinaryMessenger(), this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Message.ObsClientAPI.setup(flutterPluginBinding.getBinaryMessenger(), null);
    }

    @NonNull
    @Override
    public Message.ObsResponse uploadFile(@NonNull Message.ObsRequest request) {
        String filePath = request.getFilePath();
        String accessKey = request.getAccessKey();
        String secretKey = request.getSecretKey();
        String endpoint = request.getEndpoint();
        String bucket = request.getBucket();
        String securityToken = request.getSecurityToken();
        // 文件夹前缀，可以为空，比如桶名为jingwei，我们可以上传到jingwei桶下app文件夹下，这里就传app，为空这里直接放到根路径下
        String prefix = request.getPrefix();
        // 文件名，可以为空，指定上传文件名，为空则自动读取filePath的文件名称
        String fileName = request.getFileName();

        if (!filePath.startsWith("/")) {
            filePath = FileHelper.getRealPath(applicationContext, filePath);
        }

        if (TextUtils.isEmpty(filePath)) {
            Log.w(TAG, "file path is empty");
            throw new IllegalArgumentException("file path is empty");
        }

        Log.d(TAG, "start to upload");
        File file = new File(filePath);
        String _fileName = (null == fileName || fileName.isEmpty()) ? file.getName() : fileName;
        String objectKey = (null == prefix || prefix.isEmpty() ? "" : (prefix + "/")) + _fileName;

        ObsClient client = null;
        try {
            client = new ObsClient(accessKey, secretKey, securityToken, endpoint);
            PutObjectResult putResult = client.putObject(bucket, objectKey, file);
            return new Message.ObsResponse.Builder().setObjectUrl(putResult.getObjectUrl()).build();
        } finally {
            StreamUtils.close(client);
        }
    }
}
