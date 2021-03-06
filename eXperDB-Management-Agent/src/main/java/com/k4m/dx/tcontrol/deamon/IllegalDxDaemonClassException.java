package com.k4m.dx.tcontrol.deamon;

/**
 * DxDaemon을 구동해준다.
* @author 박태혁
* @see
* 
*      <pre>
* == 개정이력(Modification Information) ==
*
*   수정일       수정자           수정내용
*  -------     --------    ---------------------------
*  2018.04.23   박태혁 최초 생성
*      </pre>
*/

public class IllegalDxDaemonClassException extends Exception {
	Class illegalClass = null;
	
	public IllegalDxDaemonClassException(Class illegalClass) {
		super(illegalClass.getName() +
				"은 DxDaemon 인터페이스를 구현하고 있지 않습니다.");
		this.illegalClass = illegalClass;
	}
	
	public IllegalDxDaemonClassException(Class illegalClass, Throwable cause) {
		super(illegalClass.getName() +
				"은 DxDaemon 인터페이스를 구현하고 있지 않습니다.", cause);
		this.illegalClass = illegalClass;
	}
	
	/**
	 * 잘못 전달된 클래스의 객체 리턴
	 * @@return 잘못 전달된 클래스
	 */
	public Class getIllegalClass() {
		return illegalClass;
	}

}
