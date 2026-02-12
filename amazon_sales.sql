USE amazondb;
ALTER TABLE amazon_sales_dataset RENAME TO amazon_sales;
SELECT*FROM amazon_sales;
/* order_date(주문 일) , product_category(제품 카테고리), quantity_sold(구매 수량), customer_region(고객 지역)
payment_method(결제 방식), rating(상품 평점), review_count(상품리뷰 수), discounted_price(할인 금액), total_revenue(총 결제 금액) */
DESC amazon_sales;
ALTER TABLE amazon_sales MODIFY COLUMN order_date DATE;
SELECT COUNT(*) FROM amazon_sales;
## 5만개의 데이터 존재
SELECT MIN(order_date), MAX(order_date) FROM amazon_sales;
## 2022-01-01 ~ 2023-12-31 기간의 데이터
SELECT DISTINCT product_category FROM amazon_sales;
SELECT product_category, COUNT(*) 판매건수, sum(quantity_sold) 판매수량
	FROM amazon_sales 
		GROUP BY product_category
			ORDER BY 3 DESC;
-- 카테고리 : 도서(8327), 패션(8365), 스포츠(8265), 뷰티(8465), 전자(8320),생활·주방용품(8258)
SELECT * FROM amazon_sales 
	WHERE product_id = 1000;
-- 한계점 : PRODUCT_ID가 같지만 카테고리,가격,평점,리뷰수 다른 상품들이 있어서 제품별 판매량 확인 불가
SELECT customer_region AS 지역, COUNT(*) AS 판매건수, sum(quantity_sold) AS 판매수량
	FROM amazon_sales GROUP BY customer_region;
-- 지역 : 북미(12517건), 아시아(12526건), 유럽(12452건), 중동(12505건) 
SELECT customer_region AS 지역, product_category AS 카테고리, 
	COUNT(*) AS 판매건수, sum(quantity_sold) AS 판매수량, ROUND(AVG(total_revenue),2) AS 평균판매금액  
		FROM amazon_sales 
			GROUP BY customer_region, product_category
				ORDER BY 1,3 DESC;
-- ---------------------------------------------------------------------
SELECT YEAR(order_date) AS 년도, customer_region AS 지역, 
	product_category AS 카테고리, COUNT(*) AS 판매건수, sum(quantity_sold) AS 판매수량, ROUND(AVG(total_revenue),2) AS 평균판매금액
		FROM amazon_sales 
			GROUP BY YEAR(order_date), customer_region, product_category
				ORDER BY 2, 3 DESC, 1;
-- -----------------------------------------------------------------------
# 카테고리 연도별 증감률
SELECT a.카테고리, (b.판매건수 - a.판매건수) AS 증가건수, ROUND(b.평균판매금액 - a.평균판매금액,2) AS 매출차이,
 CONCAT(ROUND((b.판매건수 - a.판매건수) / a.판매건수 * 100, 2),'%') AS 증가율
FROM 
(SELECT product_category AS 카테고리, SUM(total_revenue) AS 평균판매금액, COUNT(*) AS 판매건수
    FROM amazon_sales
		WHERE YEAR(order_date) = 2022
			GROUP BY product_category) a
JOIN
(SELECT product_category AS 카테고리, SUM(total_revenue) AS 평균판매금액, COUNT(*) AS 판매건수
    FROM amazon_sales
		WHERE YEAR(order_date) = 2023
			GROUP BY product_category) b
	ON a.카테고리 = b.카테고리
			ORDER BY 1,4 DESC;
-- -----------------------------------------------------------------------
# 지역별 카테고리 연도별 증감률
SELECT a.지역, a.카테고리, (b.판매건수 - a.판매건수) AS 증가건수, ROUND(b.평균판매금액 - a.평균판매금액,2) AS 매출차이,
CONCAT(ROUND((b.판매건수 - a.판매건수) / a.판매건수 * 100, 2),'%') AS 증가율
FROM 
(SELECT customer_region AS 지역, product_category AS 카테고리, SUM(total_revenue) AS 평균판매금액,COUNT(*) AS 판매건수
    FROM amazon_sales
		WHERE YEAR(order_date) = 2022
			GROUP BY customer_region, product_category) a
JOIN 
(SELECT customer_region AS 지역, product_category AS 카테고리, SUM(total_revenue) AS 평균판매금액, COUNT(*) AS 판매건수
    FROM amazon_sales
		WHERE YEAR(order_date) = 2023
			GROUP BY customer_region, product_category) b
	ON a.지역 = b.지역
		AND a.카테고리 = b.카테고리
			ORDER BY 1,5 DESC;
