# 본문 사진

유학 정보 글(`guide/{cc}-info-*.html`) 중간에 넣는 사진을 여기에 둔다.

## 파일명
`{국가코드}-{주제}.jpg` — 예: `au-campus-flinders.jpg`, `uk-london-street.jpg`

## 글에 넣는 법
`data/articles-{cc}.json`의 `body` 안, 사진을 넣고 싶은 문단 뒤에 그대로 적는다.
빌드가 body를 통째로 넣으므로 별도 처리가 필요 없다.

```html
<figure>
  <img src="../images/article/au-campus.jpg" alt="한국어 대체 텍스트"
       data-en-alt="English alt text" loading="lazy">
  <figcaption data-en="English caption">한국어 캡션</figcaption>
</figure>
```

- **`alt`와 `data-en-alt`를 짝으로** 넣는다. 영문 모드에서 대체 텍스트도 바뀐다.
- `loading="lazy"`를 붙인다. 글 중간 사진은 첫 화면에 안 보이는 경우가 많다.
- 스타일은 `css/guide.css`의 `.article-body figure`가 처리한다(둥근 모서리·캡션·반응형).

## 규격
- 가로 1200px 이상, 16:9 또는 3:2 권장
- JPG, 200KB 이하로 압축
- **저작권**: 직접 찍었거나 상업적 이용이 가능한 것만. 대학 공식 사진은 사용 조건을 확인할 것
