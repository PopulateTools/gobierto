/* eslint-disable no-undef */
import '@testing-library/jest-dom';
import Table from './../modules/Table.vue';
import { render } from '@testing-library/vue';

describe('table vue-component', () => {
  test('should render component', () => {
    const { queryByText } = render(Table)

    const title = queryByText('Table');

    expect(title).toBeInTheDocument();
  });
});
