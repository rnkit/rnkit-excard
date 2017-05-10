package io.rnkit.excard;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

/**
 * Created by SimMan on 2017/5/9.
 */

public class EXOCRContext {
    private Context context;
    private File rootDir;

    public static boolean DEBUG = false;

    public EXOCRContext(Context context) {
        this.context = context;

        this.rootDir = new File(context.getExternalFilesDir("rnkit-excard"), "");

        if (!rootDir.exists()) {
            rootDir.mkdir();
        }
    }

    public String getTmpDirectory() {
        return rootDir.toString();
    }

    /**
     * 保存图片
     * @param bmp
     * @return
     */
    public String saveImage(Bitmap bmp, double quality) throws IOException {
        int q = quality > 0 ? (int)(quality * 100) : 75;
        Log.d("quality", q + "");
        Log.d("quality", quality + "");
        File file = new File(this.getTmpDirectory());
        if (!file.exists())
            file.mkdir();

        String filePath = this.getTmpDirectory() + "/" + java.util.UUID.randomUUID().toString() + ".jpg";

        file = new File(filePath);
        try {
            file.createNewFile();
            FileOutputStream fos = new FileOutputStream(file);
            bmp.compress(Bitmap.CompressFormat.JPEG, q, fos);
            fos.flush();
            fos.close();
            return filePath;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Bitmap getBitmap(String pathString) throws Exception {
        Bitmap bitmap = null;

        /* TODO: 2017/5/9 增加远程图片 */

        if (pathString.contains("http")) {

        }

        try {
            File file = new File(pathString);
            if(file.exists()) {
                bitmap = BitmapFactory.decodeFile(pathString);
            }
        } catch (Exception e) {

        }
        return bitmap;
    }
}