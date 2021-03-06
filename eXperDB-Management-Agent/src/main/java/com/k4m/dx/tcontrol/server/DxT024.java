package com.k4m.dx.tcontrol.server;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.simple.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.k4m.dx.tcontrol.server.DxT015.CompareNameDesc;
import com.k4m.dx.tcontrol.socket.ProtocolID;
import com.k4m.dx.tcontrol.socket.SocketCtl;
import com.k4m.dx.tcontrol.socket.TranCodeType;
import com.k4m.dx.tcontrol.util.FileEntry;
import com.k4m.dx.tcontrol.util.FileListSearcher;
import com.k4m.dx.tcontrol.util.FileUtil;

/**
 * 로그 파일 리스트 조회
 *
 * @author 박태혁
 * @see <pre>
 * == 개정이력(Modification Information) ==
 *
 *   수정일       수정자           수정내용
 *  -------     --------    ---------------------------
 *  2017.05.22   박태혁 최초 생성
 * </pre>
 */

public class DxT024 extends SocketCtl{
	
	private Logger errLogger = LoggerFactory.getLogger("errorToFile");
	private Logger socketLogger = LoggerFactory.getLogger("socketLogger");
	
	public DxT024(Socket socket, BufferedInputStream is, BufferedOutputStream	os) {
		this.client = socket;
		this.is = is;
		this.os = os;
	}

	public void execute(String strDxExCode, JSONObject jObj) throws Exception {
		
		socketLogger.info("DxT024.execute : " + strDxExCode);
		byte[] sendBuff = null;
		String strErrCode = "";
		String strErrMsg = "";
		String strSuccessCode = "0";

		String strCommandCode = (String) jObj.get(ProtocolID.COMMAND_CODE);
		String strLogFileDir = (String) jObj.get(ProtocolID.FILE_DIRECTORY);
		

		List<Map<String, Object>> outputArray = new ArrayList<Map<String, Object>>();
		

		
		JSONObject outputObj = new JSONObject();
		
		//strLogFileDir = "/home/devel/experdb/data/pg_log"
		socketLogger.info("File Dir : " + strLogFileDir);
		
		try {

			FileListSearcher fs = new FileListSearcher(strLogFileDir);
			
				List<HashMap<String, String>> resultFileList = new ArrayList<HashMap<String, String>>();
				
				List<FileEntry> fileList = fs.getSearchFiles();
				
				Collections.sort(fileList, new CompareNameDesc());
				
				for(FileEntry fn: fileList) {
					HashMap<String, String> hp = new HashMap<String, String>();
					
					String strFileName = fn.getFileName();
					String strFileSize = FileUtil.getFileSize(fn.getFileSize(), 2);
					String strLastModified = FileUtil.getFileLastModifiedDate(fn.getLastModified());
					
					String strExtender = FileUtil.fileExtenderSubString(strFileName);

					if(strExtender.equals("dump") || strExtender.equals("tar")) {
						hp.put(ProtocolID.FILE_NAME, strFileName);
						hp.put(ProtocolID.FILE_SIZE, strFileSize);
						hp.put(ProtocolID.FILE_LASTMODIFIED, strLastModified);
						
						resultFileList.add(hp);
					}
					
					

				}

				outputObj.put(ProtocolID.DX_EX_CODE, strDxExCode);
				outputObj.put(ProtocolID.RESULT_CODE, strSuccessCode);
				outputObj.put(ProtocolID.ERR_CODE, strErrCode);
				outputObj.put(ProtocolID.ERR_MSG, strErrMsg);
				outputObj.put(ProtocolID.RESULT_DATA, resultFileList);
				
				sendBuff = outputObj.toString().getBytes();
				send(4, sendBuff);

			
		} catch (Exception e) {
			errLogger.error("DxT024 {} ", e.toString());
			
			outputObj.put(ProtocolID.DX_EX_CODE, TranCodeType.DxT024);
			outputObj.put(ProtocolID.RESULT_CODE, "1");
			outputObj.put(ProtocolID.ERR_CODE, TranCodeType.DxT024);
			outputObj.put(ProtocolID.ERR_MSG, "DxT024 Error [" + e.toString() + "]");
			
			sendBuff = outputObj.toString().getBytes();
			send(4, sendBuff);

		} finally {
			outputObj = null;
			sendBuff = null;
		}	    
	}
	

    
    public static void main(String[] args) throws Exception {
		String strLogFileDir = "C:\\logs\\";
		String strFileName = "webconsole.log.2017-05-31";
		String startLen = "100";
		String seek = "0";
		
		File inFile = new File(strLogFileDir, strFileName);
		
		//byte[] buffer = FileUtil.getFileToByte(inFile);
		//HashMap hp = FileUtil.getFileView(inFile, Integer.parseInt(startLen), Integer.parseInt(dwLen));
		HashMap hp = FileUtil.getRandomAccessFileView(inFile, Integer.parseInt(startLen), Integer.parseInt(seek), 0);
		
		System.out.println(hp.get("file_desc"));
		System.out.println(hp.get("file_size"));
		System.out.println(hp.get("seek"));
		System.out.println(hp.get("end_flag"));
    }

}


