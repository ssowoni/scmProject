package kr.happyjob.study.system.service;

import java.util.List;
import java.util.Map;

import kr.happyjob.study.system.model.ComnCodUtilModel;
import kr.happyjob.study.system.model.ComnDtlCodModel;
import kr.happyjob.study.system.model.ComnGrpCodModel;
import kr.happyjob.study.system.model.comcombo;

public interface ComnComboService {

	/** 거래처 목록 조회 */
	public List<comcombo> selectclientlist(Map<String, Object> paramMap) throws Exception;
	
	/** 제품  목록 조회 */
	public List<comcombo> selectproductlist(Map<String, Object> paramMap) throws Exception;
	
	/** 창고 담당자  목록 조회 */
	public List<comcombo> selectwhpersonlist(Map<String, Object> paramMap) throws Exception;
		
	/** 창고 목록 조회 */
	public List<comcombo> selectwhlist(Map<String, Object> paramMap) throws Exception;
		
	/** 제품 분류별  목록 조회 */
	public List<comcombo> selectdivproductlist(Map<String, Object> paramMap) throws Exception;
		
				
	
	
	
}
