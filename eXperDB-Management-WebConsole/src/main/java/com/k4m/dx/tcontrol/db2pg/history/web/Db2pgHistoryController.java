package com.k4m.dx.tcontrol.db2pg.history.web;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.k4m.dx.tcontrol.common.service.HistoryVO;
import com.k4m.dx.tcontrol.db2pg.history.service.Db2pgHistoryService;
import com.k4m.dx.tcontrol.db2pg.history.service.Db2pgHistoryVO;
import com.k4m.dx.tcontrol.db2pg.setting.service.DDLConfigVO;

@Controller
public class Db2pgHistoryController {
	
	@Autowired
	private Db2pgHistoryService db2pgHistoryService;
	

	/**
	 * DB2PG 수행이력 화면을 보여준다.
	 * 
	 * @param historyVO
	 * @param request
	 * @return ModelAndView mv
	 * @throws Exception
	 */
	@RequestMapping(value = "/db2pgHistory.do")
	public ModelAndView db2pgHistory(@ModelAttribute("historyVO") HistoryVO historyVO, HttpServletRequest request) {
		ModelAndView mv = new ModelAndView();
		try {			
			mv.setViewName("db2pg/history/db2pgHistory");
		} catch (Exception e) {
			e.printStackTrace();
		}
		return mv;
	}
	
	
	/**
	 * DB2PG HISTORY 리스트를 조회한다.
	 * 
	 * @param request
	 * @return resultSet
	 * @throws Exception
	 */
	@RequestMapping(value = "/db2pg/selectDb2pgHistory.do")
	public @ResponseBody List<Db2pgHistoryVO> selectDb2pgHistory(@ModelAttribute("historyVO") HistoryVO historyVO, @ModelAttribute("db2pgHistoryVO") Db2pgHistoryVO db2pgHistoryVO, HttpServletRequest request, HttpServletResponse response) {
		List<Db2pgHistoryVO> resultSet = null;
		Map<String, Object> param = new HashMap<String, Object>();
		try {

//			// 화면접근이력 이력 남기기
//			CmmnUtils.saveHistory(request, historyVO);
//			historyVO.setExe_dtl_cd("DX-T0033_01");
//			historyVO.setMnu_id(12);
//			accessHistoryService.insertHistory(historyVO);

			resultSet = db2pgHistoryService.selectDb2pgHistory(db2pgHistoryVO);
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		return resultSet;
	}
}